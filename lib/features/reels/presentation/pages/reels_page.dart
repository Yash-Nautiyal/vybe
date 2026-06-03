import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vybe/core/widgets/loader/custom_loader.dart';

import '../bloc/reels_bloc.dart';
import '../bloc/reels_event.dart';
import '../bloc/reels_state.dart';
import '../widgets/error/error_view.dart';
import '../widgets/reel_item.dart';

import '../../reels_injection.dart';

import '../widgets/overlay/dev_reel_overlay.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key, this.reelsBloc});

  final ReelsBloc? reelsBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              (reelsBloc ?? ReelsInjection.createReelsBloc())
                ..add(const ReelsLoadRequested()),
      child: const _ReelsView(),
    );
  }
}

class _ReelsView extends StatefulWidget {
  const _ReelsView();

  @override
  State<_ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<_ReelsView> with WidgetsBindingObserver {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<ReelsBloc>();

    if (state == AppLifecycleState.paused) {
      bloc.add(const ReelsPlaybackPaused());
    } else if (state == AppLifecycleState.resumed) {
      final index =
          _pageController.hasClients ? (_pageController.page?.round() ?? 0) : 0;
      bloc.add(ReelsPlaybackResumed(index: index));
    }
  }

  @override
  void didHaveMemoryPressure() {
    context.read<ReelsBloc>().add(const ReelsMemoryWarning());
  }

  @override
  Widget build(BuildContext context) {
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.snackbarMessage!)));
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
              builder: (context, state) => _body(context, state),
            ),
            DevReelOverlay(pageController: _pageController),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ReelsState state) {
    if (state.showFullScreenLoader) {
      final textTheme = Theme.of(context).textTheme;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomLoader(size: 80, gap: 10, borderRadius: 18),
            if (state.isReseeding) ...[
              const SizedBox(height: 16),
              Text('Reseeding Firestore...', style: textTheme.bodyLarge),
            ],
          ],
        ),
      );
    }

    if (state.status == ReelsStatus.failure) {
      return ErrorView(
        message: state.errorMessage ?? 'Failed to load reels',
        onRetry:
            () => context.read<ReelsBloc>().add(const ReelsLoadRequested()),
      );
    }

    if (state.status == ReelsStatus.loaded && state.videos.isEmpty) {
      return ErrorView(
        message: 'No videos found in Firestore.',
        onRetry:
            () => context.read<ReelsBloc>().add(const ReelsLoadRequested()),
      );
    }

    if (state.status != ReelsStatus.loaded) {
      return const SizedBox.shrink();
    }

    final videoManager = context.read<ReelsBloc>().videoManager;

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: state.videos.length,
      onPageChanged: (index) {
        context.read<ReelsBloc>().add(ReelsPageChanged(index));
      },
      itemBuilder: (context, index) {
        return ReelItem(
          video: state.videos[index],
          controller: videoManager?.controllerAt(index),
          failure: videoManager?.failureAt(index),
          isBuffering: videoManager?.isBufferingAt(index) ?? false,
          onRetry: () {
            context.read<ReelsBloc>().add(ReelsVideoRetryRequested(index));
          },
        );
      },
    );
  }
}
