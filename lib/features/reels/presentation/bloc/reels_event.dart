import 'package:equatable/equatable.dart';

sealed class ReelsEvent extends Equatable {
  const ReelsEvent();

  @override
  List<Object?> get props => [];
}

final class ReelsLoadRequested extends ReelsEvent {
  const ReelsLoadRequested();
}

final class ReelsReseedRequested extends ReelsEvent {
  const ReelsReseedRequested();
}

final class ReelsClearCacheRequested extends ReelsEvent {
  const ReelsClearCacheRequested({required this.restartIndex});

  final int restartIndex;

  @override
  List<Object?> get props => [restartIndex];
}

final class ReelsPageChanged extends ReelsEvent {
  const ReelsPageChanged(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class ReelsPlaybackPaused extends ReelsEvent {
  const ReelsPlaybackPaused();
}

final class ReelsPlaybackResumed extends ReelsEvent {
  const ReelsPlaybackResumed({required this.index});

  final int index;

  @override
  List<Object?> get props => [index];
}

final class ReelsMemoryWarning extends ReelsEvent {
  const ReelsMemoryWarning();
}

final class ReelsControllerReady extends ReelsEvent {
  const ReelsControllerReady();
}

final class ReelsSnackbarDismissed extends ReelsEvent {
  const ReelsSnackbarDismissed();
}

final class ReelsScrollHandled extends ReelsEvent {
  const ReelsScrollHandled();
}

final class ReelsVideoRetryRequested extends ReelsEvent {
  const ReelsVideoRetryRequested(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class ReelLikeToggled extends ReelsEvent {
  const ReelLikeToggled(this.videoId);

  final String videoId;

  @override
  List<Object?> get props => [videoId];
}

final class ReelStarToggled extends ReelsEvent {
  const ReelStarToggled(this.videoId);

  final String videoId;

  @override
  List<Object?> get props => [videoId];
}
