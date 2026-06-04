import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:vybe/core/error/exception.dart' as app_exc;
import 'package:vybe/core/error/failures.dart';
import 'package:vybe/features/reels/data/datasources/video_cache_datasource.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

part 'reels_video_buffering_watchdog.dart';
part 'reels_video_controller_lifecycle.dart';
part 'reels_video_playback_controls.dart';

class ReelsVideoManager {
  ReelsVideoManager({
    required List<Video> videos,
    required VideoCacheDataSource cacheDataSource,
    this.onControllerReady,
    this.onPlaybackStateChanged,
  }) : _videos = videos,
       _cacheDataSource = cacheDataSource;

  final List<Video> _videos; // Feed order used by controller indexes.
  final VideoCacheDataSource _cacheDataSource; // MP4 disk cache entry point.
  final void Function(int index)? onControllerReady;
  final void Function(int index)? onPlaybackStateChanged;

  final Map<int, VideoPlayerController> _controllers = {}; // Active decoders.
  final Map<int, AppFailure> _errors = {}; // Per-reel playback failures.
  final Set<int> _bufferingIndices = {}; // Reels showing buffering UI.
  final Set<int> _warmingIndices = {}; // Background MP4 downloads in flight.
  final Set<int> _initializingIndices = {}; // Controllers currently creating.
  final Map<int, VoidCallback> _bufferingListeners = {}; // Buffer listeners.
  final Map<int, VoidCallback> _playbackGuardListeners =
      {}; // Auto-resume guards.
  final Map<int, Timer> _bufferingBannerTimers = {}; // Delayed banner timers.
  final Map<int, Timer> _bufferingTimeoutTimers =
      {}; // Long-buffer timeout timers.
  final Set<int> _userPausedIndices = {}; // Reels paused by user tap.

  int _currentIndex = 0; // Feed index allowed to play.
  bool _playbackAllowed = true; // False when shell/app intentionally pauses.

  VideoPlayerController? controllerAt(int index) => _controllers[index];

  AppFailure? failureAt(int index) => _errors[index];

  bool isBufferingAt(int index) => _bufferingIndices.contains(index);

  bool isUserPausedAt(int index) => _userPausedIndices.contains(index);

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

  Future<void> toggleUserPlayPauseAt(int index) async {
    if (!canUserTogglePlaybackAt(index)) return;

    final controller = _controllers[index]!;

    if (_userPausedIndices.contains(index)) {
      _userPausedIndices.remove(index);
      await _play(index);
    } else if (controller.value.isPlaying) {
      _userPausedIndices.add(index);
      await _safePause(controller);
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

    _playbackAllowed = false;
    _userPausedIndices.clear();
    _currentIndex = index;
    await _pauseControllersExcept(index);

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

    _playbackAllowed = true;
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

  Future<void> pauseAll() async {
    _playbackAllowed = false;
    await Future.wait(_controllers.values.map(_safePause));
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
    _disposeBufferingTimers();
    _detachAllControllerListeners();
    _disposeAllControllers();
    _errors.clear();
    _bufferingIndices.clear();
    _warmingIndices.clear();
    _initializingIndices.clear();
    _userPausedIndices.clear();
  }
}
