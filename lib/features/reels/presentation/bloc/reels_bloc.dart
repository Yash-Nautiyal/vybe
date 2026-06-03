import 'package:bloc/bloc.dart';
import 'package:vybe/features/reels/data/datasources/video_cache_datasource.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';
import 'package:vybe/features/reels/domain/usecases/clear_video_cache.dart';
import 'package:vybe/features/reels/domain/usecases/get_reels.dart';
import 'package:vybe/features/reels/domain/usecases/reseed_videos.dart';
import 'package:vybe/features/reels/domain/usecases/toggle_video_like.dart';
import 'package:vybe/features/reels/domain/usecases/toggle_video_star.dart';
import 'package:vybe/features/reels/presentation/bloc/reels_event.dart';
import 'package:vybe/features/reels/presentation/bloc/reels_state.dart';
import 'package:vybe/features/reels/presentation/services/reels_video_manager.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  ReelsBloc({
    required GetReels getReels,
    required ReseedVideos reseedVideos,
    required ClearVideoCache clearVideoCache,
    required ToggleVideoLike toggleVideoLike,
    required ToggleVideoStar toggleVideoStar,
    required VideoCacheDataSource cacheDataSource,
  }) : _getReels = getReels,
       _reseedVideos = reseedVideos,
       _clearVideoCache = clearVideoCache,
       _toggleVideoLike = toggleVideoLike,
       _toggleVideoStar = toggleVideoStar,
       _cacheDataSource = cacheDataSource,
       super(const ReelsState()) {
    on<ReelsLoadRequested>(_onLoadRequested);
    on<ReelsReseedRequested>(_onReseedRequested);
    on<ReelsClearCacheRequested>(_onClearCacheRequested);
    on<ReelsPageChanged>(_onPageChanged);
    on<ReelsPlaybackPaused>(_onPlaybackPaused);
    on<ReelsPlaybackResumed>(_onPlaybackResumed);
    on<ReelsMemoryWarning>(_onMemoryWarning);
    on<ReelsControllerReady>(_onControllerReady);
    on<ReelsSnackbarDismissed>(_onSnackbarDismissed);
    on<ReelsScrollHandled>(_onScrollHandled);
    on<ReelsVideoRetryRequested>(_onVideoRetryRequested);
    on<ReelLikeToggled>(_onLikeToggled);
    on<ReelStarToggled>(_onStarToggled);
  }

  final GetReels _getReels;
  final ReseedVideos _reseedVideos;
  final ClearVideoCache _clearVideoCache;
  final ToggleVideoLike _toggleVideoLike;
  final ToggleVideoStar _toggleVideoStar;
  final VideoCacheDataSource _cacheDataSource;

  ReelsVideoManager? _videoManager;

  ReelsVideoManager? get videoManager => _videoManager;

  // MARK: Loading Events

  Future<void> _onLoadRequested(
    ReelsLoadRequested event,
    Emitter<ReelsState> emit,
  ) async {
    await _disposePlayback();

    emit(
      state.copyWith(
        status: ReelsStatus.loading,
        clearErrorMessage: true,
        clearSnackbarMessage: true,
        clearUiActionType: true,
        clearScrollToPage: true,
      ),
    );

    final result = await _getReels();

    if (result.isSuccess) {
      final videos = result.data ?? [];
      emit(
        state.copyWith(
          status: ReelsStatus.loaded,
          videos: videos,
          clearErrorMessage: true,
        ),
      );
      await _attachPlayback(videos);
    } else {
      emit(
        state.copyWith(
          status: ReelsStatus.failure,
          errorMessage: result.failure?.message ?? 'Failed to load reels',
        ),
      );
    }
  }

  // MARK: Reseeding Events

  Future<void> _onReseedRequested(
    ReelsReseedRequested event,
    Emitter<ReelsState> emit,
  ) async {
    if (state.isBusy) return;

    await _disposePlayback();

    emit(
      state.copyWith(
        isReseeding: true,
        clearSnackbarMessage: true,
        clearUiActionType: true,
        clearScrollToPage: true,
      ),
    );

    final reseedResult = await _reseedVideos();
    if (!reseedResult.isSuccess) {
      emit(
        state.copyWith(
          isReseeding: false,
          snackbarMessage:
              'Reseed failed: ${reseedResult.failure?.message ?? 'Unknown error'}',
          uiActionType: UIActionsType.error,
        ),
      );
      return;
    }

    final clearResult = await _clearVideoCache();
    if (!clearResult.isSuccess) {
      emit(
        state.copyWith(
          isReseeding: false,
          snackbarMessage:
              'Reseed failed: ${clearResult.failure?.message ?? 'Unknown error'}',
          uiActionType: UIActionsType.error,
        ),
      );
      return;
    }

    final loadResult = await _getReels();
    if (loadResult.isSuccess) {
      final videos = loadResult.data ?? [];
      emit(
        state.copyWith(
          status: ReelsStatus.loaded,
          videos: videos,
          isReseeding: false,
          scrollToPage: 0,
          snackbarMessage: 'Firestore reseeded and feed refreshed.',
          uiActionType: UIActionsType.success,
          clearErrorMessage: true,
        ),
      );
      await _restartPlayback(videos, index: 0);
    } else {
      emit(
        state.copyWith(
          status: ReelsStatus.failure,
          isReseeding: false,
          errorMessage: loadResult.failure?.message ?? 'Failed to load reels',
        ),
      );
    }
  }

  // MARK: Cache Events

  Future<void> _onClearCacheRequested(
    ReelsClearCacheRequested event,
    Emitter<ReelsState> emit,
  ) async {
    if (state.isBusy) return;

    emit(
      state.copyWith(
        isClearingCache: true,
        clearSnackbarMessage: true,
        clearUiActionType: true,
        clearScrollToPage: true,
      ),
    );

    final result = await _clearVideoCache();

    if (result.isSuccess) {
      emit(
        state.copyWith(
          isClearingCache: false,
          snackbarMessage: 'Video cache cleared.',
          uiActionType: UIActionsType.success,
        ),
      );
      await _restartPlayback(state.videos, index: event.restartIndex);
    } else {
      emit(
        state.copyWith(
          isClearingCache: false,
          snackbarMessage:
              'Clear cache failed: ${result.failure?.message ?? 'Unknown error'}',
          uiActionType: UIActionsType.error,
        ),
      );
    }
  }

  // MARK: Playback

  Future<void> _onPageChanged(
    ReelsPageChanged event,
    Emitter<ReelsState> emit,
  ) async {
    await _videoManager?.onPageChanged(event.index);
  }

  void _onPlaybackPaused(ReelsPlaybackPaused event, Emitter<ReelsState> emit) {
    _videoManager?.pauseAll();
  }

  Future<void> _onPlaybackResumed(
    ReelsPlaybackResumed event,
    Emitter<ReelsState> emit,
  ) async {
    await _videoManager?.onPageChanged(event.index);
  }

  Future<void> _attachPlayback(List<Video> videos) async {
    await _disposePlayback();
    if (videos.isEmpty) return;

    _videoManager = _createManager(videos);
    await _videoManager!.start();
    add(const ReelsControllerReady());
  }

  Future<void> _restartPlayback(
    List<Video> videos, {
    required int index,
  }) async {
    await _disposePlayback();
    if (videos.isEmpty) return;

    _videoManager = _createManager(videos);
    await _videoManager!.start();
    if (index != 0) {
      await _videoManager!.onPageChanged(index);
    }
    add(const ReelsControllerReady());
  }

  Future<void> _onVideoRetryRequested(
    ReelsVideoRetryRequested event,
    Emitter<ReelsState> emit,
  ) async {
    try {
      await _videoManager?.retryVideo(event.index);
      if (!isClosed) {
        emit(state.copyWith(controllerVersion: state.controllerVersion + 1));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            snackbarMessage: 'Retry failed. Swipe to try another reel.',
            uiActionType: UIActionsType.error,
          ),
        );
      }
    }
  }

  void _onMemoryWarning(ReelsMemoryWarning event, Emitter<ReelsState> emit) {
    _videoManager?.onMemoryWarning();
  }

  void _onControllerReady(
    ReelsControllerReady event,
    Emitter<ReelsState> emit,
  ) {
    emit(state.copyWith(controllerVersion: state.controllerVersion + 1));
  }

  void _onSnackbarDismissed(
    ReelsSnackbarDismissed event,
    Emitter<ReelsState> emit,
  ) {
    emit(state.copyWith(clearSnackbarMessage: true, clearUiActionType: true));
  }

  // MARK: User Actions Events

  Future<void> _onLikeToggled(
    ReelLikeToggled event,
    Emitter<ReelsState> emit,
  ) async {
    final index = state.videos.indexWhere((video) => video.id == event.videoId);
    if (index == -1) return;

    final video = state.videos[index];
    final newLiked = !video.liked;
    final delta = newLiked ? 1 : -1;
    final newLikes = (video.likes + delta).clamp(0, 1 << 30);

    final optimisticVideos = List<Video>.from(state.videos);
    optimisticVideos[index] = video.copyWith(liked: newLiked, likes: newLikes);

    emit(state.copyWith(videos: optimisticVideos));

    final result = await _toggleVideoLike(
      videoId: event.videoId,
      like: newLiked,
    );

    if (result.isSuccess || isClosed) return;

    final revertedVideos = List<Video>.from(state.videos);
    revertedVideos[index] = video;

    emit(
      state.copyWith(
        videos: revertedVideos,
        snackbarMessage: 'Could not update like. Please try again.',
        uiActionType: UIActionsType.error,
      ),
    );
  }

  Future<void> _onStarToggled(
    ReelStarToggled event,
    Emitter<ReelsState> emit,
  ) async {
    final index = state.videos.indexWhere((video) => video.id == event.videoId);
    if (index == -1) return;

    final video = state.videos[index];
    final newStarred = !video.starred;
    final delta = newStarred ? 1 : -1;
    final newStarredCount = (video.starredCount + delta).clamp(0, 1 << 30);

    final optimisticVideos = List<Video>.from(state.videos);
    optimisticVideos[index] = video.copyWith(
      starred: newStarred,
      starredCount: newStarredCount,
    );

    emit(state.copyWith(videos: optimisticVideos));

    final result = await _toggleVideoStar(
      videoId: event.videoId,
      star: newStarred,
    );

    if (result.isSuccess || isClosed) return;

    final revertedVideos = List<Video>.from(state.videos);
    revertedVideos[index] = video;

    emit(
      state.copyWith(
        videos: revertedVideos,
        snackbarMessage: 'Could not update star. Please try again.',
        uiActionType: UIActionsType.error,
      ),
    );
  }

  void _onScrollHandled(ReelsScrollHandled event, Emitter<ReelsState> emit) {
    emit(state.copyWith(clearScrollToPage: true));
  }

  // MARK: Helper 

  ReelsVideoManager _createManager(List<Video> videos) {
    return ReelsVideoManager(
      videos: videos,
      cacheDataSource: _cacheDataSource,
      onControllerReady: (_) {
        if (!isClosed) add(const ReelsControllerReady());
      },
      onPlaybackStateChanged: (_) {
        if (!isClosed) add(const ReelsControllerReady());
      },
    );
  }

  // MARK: Disposal

  Future<void> _disposePlayback() async {
    _videoManager?.dispose();
    _videoManager = null;
  }

  @override
  Future<void> close() async {
    await _disposePlayback();
    return super.close();
  }
}
