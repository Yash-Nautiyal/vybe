part of 'reels_video_manager.dart';

extension ReelsVideoBufferingWatchdog on ReelsVideoManager {
  static const _bufferingBannerDelay = Duration(seconds: 8);
  static const _bufferingTimeoutDelay = Duration(seconds: 30);

  void _attachBufferingWatchdog(int index, VideoPlayerController controller) {
    _detachBufferingWatchdog(index);

    void listener() {
      if (!controller.value.isInitialized) return;

      if (controller.value.isBuffering) {
        _scheduleBufferingWatchdog(index);
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

  void _scheduleBufferingWatchdog(int index) {
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

          unawaited(_safePause(current));
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

  void _disposeBufferingTimers() {
    for (final timer in _bufferingBannerTimers.values) {
      timer.cancel();
    }
    for (final timer in _bufferingTimeoutTimers.values) {
      timer.cancel();
    }
    _bufferingBannerTimers.clear();
    _bufferingTimeoutTimers.clear();
  }

  void _detachAllControllerListeners() {
    for (final index in _bufferingListeners.keys.toList()) {
      _detachBufferingWatchdog(index);
    }
    for (final index in _playbackGuardListeners.keys.toList()) {
      _detachPlaybackGuard(index);
    }
  }
}
