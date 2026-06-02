import 'package:equatable/equatable.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

enum ReelsStatus { initial, loading, loaded, failure }

class ReelsState extends Equatable {
  const ReelsState({
    this.status = ReelsStatus.initial,
    this.videos = const [],
    this.errorMessage,
    this.isReseeding = false,
    this.isClearingCache = false,
    this.snackbarMessage,
    this.scrollToPage,
    this.controllerVersion = 0,
  });

  final ReelsStatus status;
  final List<Video> videos;
  final String? errorMessage;
  final bool isReseeding;
  final bool isClearingCache;
  final String? snackbarMessage;
  final int? scrollToPage;
  final int controllerVersion;

  bool get isBusy => isReseeding || isClearingCache;
  bool get showFullScreenLoader =>
      status == ReelsStatus.loading || isReseeding;

  ReelsState copyWith({
    ReelsStatus? status,
    List<Video>? videos,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isReseeding,
    bool? isClearingCache,
    String? snackbarMessage,
    bool clearSnackbarMessage = false,
    int? scrollToPage,
    bool clearScrollToPage = false,
    int? controllerVersion,
  }) {
    return ReelsState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isReseeding: isReseeding ?? this.isReseeding,
      isClearingCache: isClearingCache ?? this.isClearingCache,
      snackbarMessage:
          clearSnackbarMessage
              ? null
              : (snackbarMessage ?? this.snackbarMessage),
      scrollToPage:
          clearScrollToPage ? null : (scrollToPage ?? this.scrollToPage),
      controllerVersion: controllerVersion ?? this.controllerVersion,
    );
  }

  @override
  List<Object?> get props => [
    status,
    videos,
    errorMessage,
    isReseeding,
    isClearingCache,
    snackbarMessage,
    scrollToPage,
    controllerVersion,
  ];
}
