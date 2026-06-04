import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:vybe/core/error/exception.dart' as app_exc;
import 'package:vybe/core/error/failures.dart';
import 'package:vybe/features/reels/data/datasources/video_cache_datasource.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

/// Orchestrates playback, preload, and pause for the vertical feed.
///
/// Controllers (decoders): current index ± 1 only.
/// Disk warm-cache: +2 and +3 ahead — download only, no [VideoPlayerController].
class ReelsVideoManager {
  ReelsVideoManager({
    required List<Video> videos,
    required VideoCacheDataSource cacheDataSource,
    this.onControllerReady,
    this.onPlaybackStateChanged,
  }) : _videos = videos,
       _cacheDataSource = cacheDataSource;

  final List<Video> _videos;
  final VideoCacheDataSource _cacheDataSource;
  final void Function(int index)? onControllerReady;
  final void Function(int index)? onPlaybackStateChanged;

  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, AppFailure> _errors = {};
  final Set<int> _bufferingIndices = {};
  final Set<int> _warmingIndices = {};
  final Set<int> _initializingIndices = {};
  final Map<int, VoidCallback> _bufferingListeners = {};
  final Map<int, VoidCallback> _playbackGuardListeners = {};
  final Map<int, Timer> _bufferingBannerTimers = {};
  final Map<int, Timer> _bufferingTimeoutTimers = {};
  final Set<int> _userPausedIndices = {};

  int _currentIndex = 0;
  bool _playbackAllowed = true;

  static const _initTimeout = Duration(seconds: 10);
  static const _bufferingBannerDelay = Duration(seconds: 8);
  static const _bufferingTimeoutDelay = Duration(seconds: 30);

  // ─────────────────────────────────────────
  // MARK: Public API
  // ─────────────────────────────────────────

  VideoPlayerController? controllerAt(int index) => _controllers[index];

  AppFailure? failureAt(int index) => _errors[index];

  bool isBufferingAt(int index) => _bufferingIndices.contains(index);

  bool isUserPausedAt(int index) => _userPausedIndices.contains(index);

  /// True when the decoder is ready and not in a network/buffering state.
  bool canUserTogglePlaybackAt(int index) {
    if (index != _currentIndex) return false;
    if (_errors[index] != null) return false;
    if (_initializingIndices.contains(index)) return false;
    if (_bufferingIndices.contains(index)) return false;

    final controller = _controllers[index];
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.hasError ||
        controller.value.isBuffering) {
      return false;
    }
    return true;
  }

  /// Tap play/pause for a loaded, non-buffering reel at [index].
  Future<void> toggleUserPlayPauseAt(int index) async {
    if (!canUserTogglePlaybackAt(index)) return;

    final controller = _controllers[index]!;

    if (_userPausedIndices.contains(index)) {
      _userPausedIndices.remove(index);
      await _play(index);
    } else if (controller.value.isPlaying) {
      _userPausedIndices.add(index);
      _safePause(controller);
    }

    onPlaybackStateChanged?.call(index);
  }

  Future<void> start() async {
    if (_videos.isEmpty) return;

    await _ensureController(0);
    if (_errors[0] == null) {
      await _play(0);
    }

    unawaited(_ensureController(1));
    _warmCache(2);
    _warmCache(3);
  }

  Future<void> onPageChanged(int index) async {
    if (index < 0 || index >= _videos.length) return;

    _playbackAllowed = true;
    _userPausedIndices.clear();
    _safePause(_controllers[_currentIndex]);
    _currentIndex = index;

    final tasks = <Future<void>>[];
    if (index > 0) {
      tasks.add(_ensureController(index - 1));
    }
    tasks.add(_ensureController(index));
    if (index + 1 < _videos.length) {
      tasks.add(_ensureController(index + 1));
    }
    await Future.wait(
      tasks.map((task) => task.catchError((Object _, StackTrace __) {})),
    );

    if (_errors[index] == null) {
      await _play(index);
    }
    _warmCache(index + 2);
    _warmCache(index + 3);
    _disposeControllersOutsideWindow(index);
  }

  /// Clears error state, evicts cache, and re-attempts init for [index].
  Future<void> retryVideo(int index) async {
    if (index < 0 || index >= _videos.length) return;

    _errors.remove(index);
    _clearBufferingState(index);
    onPlaybackStateChanged?.call(index);

    final url = _videos[index].videoUrl;
    await _cacheDataSource.removeVideo(url);

    final existing = _controllers.remove(index);
    _detachBufferingWatchdog(index);
    _detachPlaybackGuard(index);
    await existing?.dispose();

    await _ensureController(index);

    if (index == _currentIndex && _errors[index] == null) {
      await _play(index);
    }
    onPlaybackStateChanged?.call(index);
  }

  void pauseAll() {
    _playbackAllowed = false;
    for (final controller in _controllers.values) {
      _safePause(controller);
    }
  }

  Future<void> resumeAt(int index) async {
    if (index < 0 || index >= _videos.length) return;

    _playbackAllowed = true;
    _userPausedIndices.remove(index);
    if (index == _currentIndex) {
      if (_errors[index] == null) {
        await _play(index);
      }
      return;
    }

    await onPageChanged(index);
  }

  /// Drops distant controllers under memory pressure; disk cache is untouched.
  void onMemoryWarning() {
    _disposeControllersOutsideWindow(_currentIndex);
  }

  void dispose() {
    for (final timer in _bufferingBannerTimers.values) {
      timer.cancel();
    }
    for (final timer in _bufferingTimeoutTimers.values) {
      timer.cancel();
    }
    _bufferingBannerTimers.clear();
    _bufferingTimeoutTimers.clear();

    for (final index in _bufferingListeners.keys.toList()) {
      _detachBufferingWatchdog(index);
    }
    for (final index in _playbackGuardListeners.keys.toList()) {
      _detachPlaybackGuard(index);
    }

    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _errors.clear();
    _bufferingIndices.clear();
    _warmingIndices.clear();
    _initializingIndices.clear();
    _userPausedIndices.clear();
  }

  // ─────────────────────────────────────────
  // MARK: Controller Lifecycle
  // ─────────────────────────────────────────

  Future<void> _ensureController(int index) async {
    if (index < 0 || index >= _videos.length) return;
    if (_controllers.containsKey(index)) return;
    if (_initializingIndices.contains(index)) return;

    _initializingIndices.add(index);
    _errors.remove(index);

    try {
      final url = _videos[index].videoUrl;

      try {
        await _initControllerAt(index, url);
      } on app_exc.NetworkException {
        _errors[index] = const NetworkFailure();
        onPlaybackStateChanged?.call(index);
      } on app_exc.TimeoutException {
        _errors[index] = const TimeoutFailure();
        onPlaybackStateChanged?.call(index);
      } catch (error, stackTrace) {
        debugPrint('Unexpected error loading video at $index: $error');
        debugPrint('$stackTrace');
        _errors[index] = const CacheFailure('Video unplayable.');
        onPlaybackStateChanged?.call(index);
      }
    } finally {
      _initializingIndices.remove(index);
    }
  }

  Future<void> _initControllerAt(int index, String url) async {
    var file = await _cacheDataSource.getVideoFile(url);
    var decoderRetried = false;

    while (true) {
      final controller = VideoPlayerController.file(
        file,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      try {
        await controller
            .initialize()
            .timeout(
              _initTimeout,
              onTimeout: () => throw app_exc.TimeoutException(),
            );
        await controller.setLooping(true);
        _controllers[index] = controller;
        _attachBufferingWatchdog(index, controller);
        _attachPlaybackGuard(index, controller);
        onControllerReady?.call(index);
        return;
      } catch (error, stackTrace) {
        await controller.dispose();

        if (_isDecoderError(error) && !decoderRetried) {
          decoderRetried = true;
          await _cacheDataSource.removeVideo(url);
          file = await _cacheDataSource.getVideoFile(url);
          continue;
        }

        if (error is app_exc.TimeoutException) {
          _errors[index] = const TimeoutFailure();
        } else if (_isDecoderError(error) || decoderRetried) {
          _errors[index] = const CacheFailure('Video unplayable.');
        } else {
          _errors[index] = const CacheFailure('Video unplayable.');
        }
        debugPrint('Failed to init video at $index: $error');
        debugPrint('$stackTrace');
        onPlaybackStateChanged?.call(index);
        return;
      }
    }
  }

  /// Downloads MP4 to disk only — no decoder, no RAM for a player.
  void _warmCache(int index) {
    if (index < 0 || index >= _videos.length) return;
    if (_warmingIndices.contains(index)) return;

    _warmingIndices.add(index);
    final url = _videos[index].videoUrl;
    () async {
      try {
        await _cacheDataSource.getVideoFile(url);
      } catch (_) {
        // Background warm-cache failures are intentionally silent.
      } finally {
        _warmingIndices.remove(index);
      }
    }();
  }

  Future<void> _play(int index) async {
    final controller = _controllers[index];
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.hasError ||
        _userPausedIndices.contains(index)) {
      return;
    }

    if (!_playbackAllowed || index != _currentIndex) return;

    try {
      await controller.play();
    } catch (error, stackTrace) {
      debugPrint('Failed to play video at $index: $error');
      debugPrint('$stackTrace');
    }
  }

  void _disposeControllersOutsideWindow(int index) {
    final keysToRemove =
        _controllers.keys.where((key) => (key - index).abs() > 1).toList();

    for (final key in keysToRemove) {
      _detachBufferingWatchdog(key);
      _detachPlaybackGuard(key);
      _controllers.remove(key)?.dispose();
      _errors.remove(key);
    }
  }

  // ─────────────────────────────────────────
  // MARK: Buffering Watchdog
  // ─────────────────────────────────────────

  void _attachBufferingWatchdog(int index, VideoPlayerController controller) {
    _detachBufferingWatchdog(index);

    void listener() {
      if (!controller.value.isInitialized) return;

      if (controller.value.isBuffering) {
        _scheduleBufferingWatchdog(index, controller);
      } else {
        final hadVisibleBuffering = _bufferingIndices.contains(index);
        _clearBufferingState(index);
        if (hadVisibleBuffering) {
          onPlaybackStateChanged?.call(index);
        }
      }
    }

    _bufferingListeners[index] = listener;
    controller.addListener(listener);
  }

  void _scheduleBufferingWatchdog(
    int index,
    VideoPlayerController controller,
  ) {
    if (_bufferingBannerTimers.containsKey(index)) return;

    _bufferingBannerTimers[index] = Timer(_bufferingBannerDelay, () {
      _bufferingBannerTimers.remove(index);
      final active = _controllers[index];
      if (active == null || !active.value.isBuffering) return;

      _bufferingIndices.add(index);
      onPlaybackStateChanged?.call(index);

      _bufferingTimeoutTimers[index] = Timer(
        _bufferingTimeoutDelay - _bufferingBannerDelay,
        () {
          _bufferingTimeoutTimers.remove(index);
          final current = _controllers[index];
          if (current == null || !current.value.isBuffering) return;

          _safePause(current);
          _clearBufferingState(index);
          _errors[index] = const TimeoutFailure();
          onPlaybackStateChanged?.call(index);
        },
      );
    });
  }

  void _clearBufferingState(int index) {
    _bufferingBannerTimers.remove(index)?.cancel();
    _bufferingTimeoutTimers.remove(index)?.cancel();
    _bufferingIndices.remove(index);
  }

  void _detachBufferingWatchdog(int index) {
    final listener = _bufferingListeners.remove(index);
    final controller = _controllers[index];
    if (listener != null && controller != null) {
      controller.removeListener(listener);
    }
    _clearBufferingState(index);
  }

  void _attachPlaybackGuard(int index, VideoPlayerController controller) {
    _detachPlaybackGuard(index);

    void listener() {
      if (!_playbackAllowed || index != _currentIndex) return;
      if (_userPausedIndices.contains(index)) return;
      if (!controller.value.isInitialized ||
          controller.value.hasError ||
          controller.value.isBuffering ||
          controller.value.isPlaying) {
        return;
      }

      unawaited(_play(index));
    }

    _playbackGuardListeners[index] = listener;
    controller.addListener(listener);
  }

  void _detachPlaybackGuard(int index) {
    final listener = _playbackGuardListeners.remove(index);
    final controller = _controllers[index];
    if (listener != null && controller != null) {
      controller.removeListener(listener);
    }
  }

  // ─────────────────────────────────────────
  // MARK: Utilities
  // ─────────────────────────────────────────

  void _safePause(VideoPlayerController? controller) {
    if (controller == null || !controller.value.isInitialized) return;

    try {
      controller.pause();
    } catch (error, stackTrace) {
      debugPrint('Failed to pause controller: $error');
      debugPrint('$stackTrace');
    }
  }

  bool _isDecoderError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('-1010') || message.contains('decoder');
  }
}
