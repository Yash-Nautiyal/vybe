import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vybe/core/theme/app_pallete.dart';
import 'package:vybe/core/widgets/loader/custom_loader.dart';
import 'package:vybe/features/reels/presentation/bloc/reels_bloc.dart';
import 'package:vybe/features/reels/presentation/bloc/reels_event.dart';
import 'package:vybe/features/reels/presentation/bloc/reels_state.dart';
import 'package:vybe/features/reels/presentation/widgets/reel_item.dart';
import 'package:vybe/features/reels/reels_injection.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key, this.reelsBloc});

  /// Optional override for tests.
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
        backgroundColor: AppPallete.black,
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
              builder: (context, state) => _buildBody(context, state),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: BlocBuilder<ReelsBloc, ReelsState>(
                    builder: (context, state) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _DevActionButton(
                            label: 'Reseed DB',
                            loadingLabel: 'Reseeding',
                            icon: Icons.refresh,
                            isLoading:
                                state.isReseeding || state.isClearingCache,
                            onPressed: () {
                              context.read<ReelsBloc>().add(
                                const ReelsReseedRequested(),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _DevActionButton(
                            label: 'Clear Cache',
                            loadingLabel: 'Clearing',
                            icon: Icons.delete_outline,
                            isLoading:
                                state.isClearingCache || state.isReseeding,
                            onPressed: () {
                              final index =
                                  _pageController.hasClients
                                      ? (_pageController.page?.round() ?? 0)
                                      : 0;
                              context.read<ReelsBloc>().add(
                                ReelsClearCacheRequested(restartIndex: index),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReelsState state) {
    if (state.showFullScreenLoader) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomLoader(size: 80, gap: 10, borderRadius: 18),
            if (state.isReseeding) ...[
              const SizedBox(height: 16),
              const Text(
                'Reseeding Firestore...',
                style: TextStyle(color: AppPallete.white),
              ),
            ],
          ],
        ),
      );
    }

    if (state.status == ReelsStatus.failure) {
      return _ErrorView(
        message: state.errorMessage ?? 'Failed to load reels',
        onRetry:
            () => context.read<ReelsBloc>().add(const ReelsLoadRequested()),
      );
    }

    if (state.status == ReelsStatus.loaded && state.videos.isEmpty) {
      return _ErrorView(
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

class _DevActionButton extends StatelessWidget {
  const _DevActionButton({
    required this.label,
    required this.loadingLabel,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final String loadingLabel;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPallete.grey800.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppPallete.white,
                  ),
                )
              else
                Icon(icon, color: AppPallete.white, size: 18),
              const SizedBox(width: 8),
              Text(
                isLoading ? loadingLabel : label,
                style: const TextStyle(
                  color: AppPallete.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppPallete.errorMain,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load reels',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppPallete.white),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppPallete.grey500),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
