import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
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
  }) : _videos = videos,
       _cacheDataSource = cacheDataSource;

  final List<Video> _videos;
  final VideoCacheDataSource _cacheDataSource;
  final void Function(int index)? onControllerReady;

  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _warmingIndices = {};
  int _currentIndex = 0;

  VideoPlayerController? controllerAt(int index) => _controllers[index];

  /// Launch: video 0 gets full bandwidth, then background preload.
  Future<void> start() async {
    if (_videos.isEmpty) return;

    await _ensureController(0);
    await _play(0);

    _ensureController(1);
    _warmCache(2);
    _warmCache(3);
  }

  /// Scroll: parallel init for N±1, disk-only warm for N+2/+3.
  Future<void> onPageChanged(int index) async {
    if (index < 0 || index >= _videos.length) return;

    _controllers[_currentIndex]?.pause();
    _currentIndex = index;

    final tasks = <Future<void>>[];
    if (index > 0) {
      tasks.add(_ensureController(index - 1));
    }
    tasks.add(_ensureController(index));
    if (index + 1 < _videos.length) {
      tasks.add(_ensureController(index + 1));
    }
    await Future.wait(tasks);

    await _play(index);
    _warmCache(index + 2);
    _warmCache(index + 3);
    _disposeControllersOutsideWindow(index);
  }

  void pauseAll() {
    for (final controller in _controllers.values) {
      controller.pause();
    }
  }

  /// Drops distant controllers under memory pressure; disk cache is untouched.
  void onMemoryWarning() {
    _disposeControllersOutsideWindow(_currentIndex);
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _warmingIndices.clear();
  }

  Future<void> _ensureController(int index) async {
    if (index < 0 || index >= _videos.length) return;
    if (_controllers.containsKey(index)) return;

    final video = _videos[index];
    final file = await _cacheDataSource.getVideoFile(video.videoUrl);
    final controller = VideoPlayerController.file(file);

    try {
      await controller.initialize();
      await controller.setLooping(true);
      _controllers[index] = controller;
      onControllerReady?.call(index);
    } catch (error, stackTrace) {
      await controller.dispose();
      debugPrint('Failed to init video at $index: $error');
      debugPrint('$stackTrace');
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
      } catch (error, stackTrace) {
        debugPrint('Warm cache failed at $index: $error');
        debugPrint('$stackTrace');
      } finally {
        _warmingIndices.remove(index);
      }
    }();
  }

  Future<void> _play(int index) async {
    final controller = _controllers[index];
    if (controller == null || !controller.value.isInitialized) return;
    await controller.play();
  }

  void _disposeControllersOutsideWindow(int index) {
    final keysToRemove = _controllers.keys
        .where((key) => (key - index).abs() > 1)
        .toList();

    for (final key in keysToRemove) {
      _controllers.remove(key)?.dispose();
    }
  }
}
