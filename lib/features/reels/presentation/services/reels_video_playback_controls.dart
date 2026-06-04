part of 'reels_video_manager.dart';

extension ReelsVideoPlaybackControls on ReelsVideoManager {
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
      await _pauseControllersExcept(index);
      await controller.play();
    } catch (error, stackTrace) {
      debugPrint('Failed to play video at $index: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _pauseControllersExcept(int index) {
    return Future.wait(
      _controllers.entries
          .where((entry) => entry.key != index)
          .map((entry) => _safePause(entry.value)),
    );
  }

  Future<void> _safePause(VideoPlayerController? controller) async {
    if (controller == null || !controller.value.isInitialized) return;

    try {
      await controller.pause();
    } catch (error, stackTrace) {
      debugPrint('Failed to pause controller: $error');
      debugPrint('$stackTrace');
    }
  }
}
