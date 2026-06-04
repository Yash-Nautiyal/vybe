import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vybe/core/widgets/dialog/snackbar_dialog.dart';
import 'package:vybe/core/widgets/loader/custom_loader.dart';

import '../bloc/reels_bloc.dart';
import '../bloc/reels_event.dart';
import '../bloc/reels_state.dart';
import '../widgets/error/error_view.dart';
import '../widgets/reel_item.dart';

import '../../reels_injection.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key, this.reelsBloc, this.onReelIndexChanged});

  final ReelsBloc? reelsBloc;
  final ValueChanged<int>? onReelIndexChanged;

  @override
  Widget build(BuildContext context) {
    final view = _ReelsView(onReelIndexChanged: onReelIndexChanged);

    if (reelsBloc != null) {
      return BlocProvider.value(value: reelsBloc!, child: view);
    }

    return BlocProvider(
      create:
          (_) =>
              ReelsInjection.createReelsBloc()..add(const ReelsLoadRequested()),
      child: view,
    );
  }
}

class _ReelsView extends StatefulWidget {
  const _ReelsView({this.onReelIndexChanged});

  final ValueChanged<int>? onReelIndexChanged;

  @override
  State<_ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<_ReelsView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  int get _currentPageIndex =>
      _pageController.hasClients ? (_pageController.page?.round() ?? 0) : 0;

  bool get _isAppBackgrounded =>
      _lifecycleState == AppLifecycleState.hidden ||
      _lifecycleState == AppLifecycleState.detached;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    final bloc = context.read<ReelsBloc>();

    if (_isAppBackgrounded) {
      bloc.add(const ReelsPlaybackPaused());
      return;
    }

    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      bloc.add(ReelsPlaybackResumed(index: _currentPageIndex));
    }
  }

  @override
  void didHaveMemoryPressure() {
    context.read<ReelsBloc>().add(const ReelsMemoryWarning());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<ReelsBloc, ReelsState>(
      listenWhen: (previous, current) {
        if (current.snackbarMessage != null &&
            previous.snackbarMessage != current.snackbarMessage) {
          return true;
        }
        if (current.scrollToPage != null &&
            previous.scrollToPage != current.scrollToPage) {
          return true;
        }
        return false;
      },
      listener: (context, state) async {
        if (state.scrollToPage != null && _pageController.hasClients) {
          await _pageController.animateToPage(
            state.scrollToPage!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          if (context.mounted) {
            context.read<ReelsBloc>().add(const ReelsScrollHandled());
          }
        }

        if (state.snackbarMessage != null && context.mounted) {
          final snackbarType =
              state.uiActionType == UIActionsType.error
                  ? SnackbarType.error
                  : SnackbarType.success;
          showAnimatedSnackbar(context, state.snackbarMessage!, snackbarType);
          context.read<ReelsBloc>().add(const ReelsSnackbarDismissed());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            BlocBuilder<ReelsBloc, ReelsState>(
              buildWhen:
                  (previous, current) =>
                      previous.status != current.status ||
                      previous.videos != current.videos ||
                      previous.isReseeding != current.isReseeding ||
                      previous.isClearingCache != current.isClearingCache ||
                      previous.errorMessage != current.errorMessage ||
                      previous.controllerVersion != current.controllerVersion,
              builder: (context, state) {
                // MARK: Loader

                if (state.showFullScreenLoader) {
                  final textTheme = Theme.of(context).textTheme;

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomLoader(size: 80, gap: 10, borderRadius: 18),
                        if (state.isReseeding) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Reseeding Firestore...',
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // MARK: Error

                if (state.status == ReelsStatus.failure) {
                  return ErrorView(
                    message: state.errorMessage ?? 'Failed to load reels',
                    onRetry:
                        () => context.read<ReelsBloc>().add(
                          const ReelsLoadRequested(),
                        ),
                  );
                }

                if (state.status == ReelsStatus.loaded &&
                    state.videos.isEmpty) {
                  return ErrorView(
                    message: 'No videos found in Firestore.',
                    onRetry:
                        () => context.read<ReelsBloc>().add(
                          const ReelsLoadRequested(),
                        ),
                  );
                }

                // MARK: Body

                if (state.status != ReelsStatus.loaded) {
                  return const SizedBox.shrink();
                }

                final videoManager = context.read<ReelsBloc>().videoManager;

                return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: state.videos.length,
                  onPageChanged: (index) {
                    widget.onReelIndexChanged?.call(index);
                    context.read<ReelsBloc>().add(ReelsPageChanged(index));
                  },
                  itemBuilder: (context, index) {
                    return ReelItem(
                      index: index,
                      video: state.videos[index],
                      controller: videoManager?.controllerAt(index),
                      failure: videoManager?.failureAt(index),
                      isBuffering: videoManager?.isBufferingAt(index) ?? false,
                      isUserPaused:
                          videoManager?.isUserPausedAt(index) ?? false,
                      canTogglePlayPause:
                          videoManager?.canUserTogglePlaybackAt(index) ?? false,
                      onRetry: () {
                        context.read<ReelsBloc>().add(
                          ReelsVideoRetryRequested(index),
                        );
                      },
                    );
                  },
                );
              },
            ),
            // DevReelOverlay(pageController: _pageController),
          ],
        ),
      ),
    );
  }
}
