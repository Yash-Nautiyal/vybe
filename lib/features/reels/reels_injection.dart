import 'package:vybe/core/network/app_network.dart';
import 'package:vybe/core/network/network_info.dart';
import 'package:vybe/features/reels/data/datasources/reels_remote_datasource.dart';
import 'package:vybe/features/reels/data/datasources/seed_local_datasource.dart';
import 'package:vybe/features/reels/data/datasources/video_cache_datasource.dart';
import 'package:vybe/features/reels/data/datasources/reels_local_datasource.dart';
import 'package:vybe/features/reels/data/repositories/reels_repository_impl.dart';
import 'package:vybe/features/reels/data/repositories/seed_repository_impl.dart';
import 'package:vybe/features/reels/data/repositories/video_cache_repository_impl.dart';
import 'package:vybe/features/reels/domain/repositories/reels_repository.dart';
import 'package:vybe/features/reels/domain/repositories/seed_repository.dart';
import 'package:vybe/features/reels/domain/repositories/video_cache_repository.dart';
import 'package:vybe/features/reels/domain/usecases/clear_video_cache.dart';
import 'package:vybe/features/reels/domain/usecases/get_reels.dart';
import 'package:vybe/features/reels/domain/usecases/reseed_videos.dart';
import 'package:vybe/features/reels/domain/usecases/toggle_video_like.dart';
import 'package:vybe/features/reels/domain/usecases/toggle_video_star.dart';
import 'package:vybe/features/reels/presentation/bloc/reels_bloc.dart';

/// Composition root: wires data implementations to domain use cases and presentation.
class ReelsInjection {
  ReelsInjection._();

  static ReelsRepository? _repository;
  static SeedRepository? _seedRepository;
  static VideoCacheRepository? _videoCacheRepository;
  static ReelsLocalDataSource? _interactionsLocalDataSource;
  static GetReels? _getReels;
  static ReseedVideos? _reseedVideos;
  static ClearVideoCache? _clearVideoCache;
  static ToggleVideoLike? _toggleVideoLike;
  static ToggleVideoStar? _toggleVideoStar;
  static VideoCacheDataSource? _videoCacheDataSource;

  static NetworkInfo get networkInfo => AppNetwork.instance;

  static ReelsLocalDataSource get interactionsLocalDataSource {
    _interactionsLocalDataSource ??= ReelsLocalDataSourceImpl();
    return _interactionsLocalDataSource!;
  }

  static ReelsRepository get repository {
    _repository ??= ReelsRepositoryImpl(
      ReelsRemoteDataSourceImpl(networkInfo: networkInfo),
      interactionsLocalDataSource,
    );
    return _repository!;
  }

  static SeedRepository get seedRepository {
    _seedRepository ??= SeedRepositoryImpl(SeedLocalDataSourceImpl());
    return _seedRepository!;
  }

  static VideoCacheRepository get videoCacheRepository {
    _videoCacheRepository ??= VideoCacheRepositoryImpl();
    return _videoCacheRepository!;
  }

  static GetReels get getReels {
    _getReels ??= GetReels(repository);
    return _getReels!;
  }

  static ReseedVideos get reseedVideos {
    _reseedVideos ??= ReseedVideos(seedRepository);
    return _reseedVideos!;
  }

  static ClearVideoCache get clearVideoCache {
    _clearVideoCache ??= ClearVideoCache(videoCacheRepository);
    return _clearVideoCache!;
  }

  static ToggleVideoLike get toggleVideoLike {
    _toggleVideoLike ??= ToggleVideoLike(repository);
    return _toggleVideoLike!;
  }

  static ToggleVideoStar get toggleVideoStar {
    _toggleVideoStar ??= ToggleVideoStar(repository);
    return _toggleVideoStar!;
  }

  static VideoCacheDataSource get videoCache {
    _videoCacheDataSource ??= VideoCacheDataSourceImpl();
    return _videoCacheDataSource!;
  }

  static ReelsBloc createReelsBloc() {
    return ReelsBloc(
      getReels: getReels,
      reseedVideos: reseedVideos,
      clearVideoCache: clearVideoCache,
      toggleVideoLike: toggleVideoLike,
      toggleVideoStar: toggleVideoStar,
      cacheDataSource: videoCache,
    );
  }
}
