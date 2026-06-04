part of 'reels_video_manager.dart';

extension ReelsVideoControllerLifecycle on ReelsVideoManager {
  static const _initTimeout = Duration(seconds: 10);

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
        await controller.initialize().timeout(
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

        _errors[index] =
            error is app_exc.TimeoutException
                ? const TimeoutFailure()
                : const CacheFailure('Video unplayable.');
        debugPrint('Failed to init video at $index: $error');
        debugPrint('$stackTrace');
        onPlaybackStateChanged?.call(index);
        return;
      }
    }
  }

  void _warmCache(int index) {
    if (index < 0 || index >= _videos.length) return;
    if (_warmingIndices.contains(index)) return;

    _warmingIndices.add(index);
    final url = _videos[index].videoUrl;
    () async {
      try {
        await _cacheDataSource.getVideoFile(url);
      } catch (_) {
        // Best effort only: foreground initialization reports real failures.
      } finally {
        _warmingIndices.remove(index);
      }
    }();
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

  void _disposeAllControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  bool _isDecoderError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('-1010') || message.contains('decoder');
  }
}
