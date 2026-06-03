import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vybe/core/error/failures.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

import 'error/video_error_overlay.dart';
import 'overlay/reel_overlay.dart';

class ReelItem extends StatelessWidget {
  const ReelItem({
    super.key,
    required this.video,
    this.controller,
    this.failure,
    this.isBuffering = false,
    this.onRetry,
  });

  final Video video;
  final VideoPlayerController? controller;
  final AppFailure? failure;
  final bool isBuffering;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _VideoBackground(
          controller: controller,
          thumbnailUrl: video.thumbnailUrl,
          showLoading: failure == null,
        ),
        if (failure != null)
          VideoErrorOverlay(failure: failure!, onRetry: onRetry),
        const _BottomGradient(),
        ReelOverlay(video: video),
        if (isBuffering && failure == null) const _BufferingBanner(),
      ],
    );
  }
}

class _VideoBackground extends StatefulWidget {
  const _VideoBackground({
    required this.controller,
    required this.thumbnailUrl,
    required this.showLoading,
  });

  final VideoPlayerController? controller;
  final String thumbnailUrl;
  final bool showLoading;

  @override
  State<_VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<_VideoBackground> {
  bool _isInitialized = false;
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    _attachListener(widget.controller);
  }

  @override
  void didUpdateWidget(covariant _VideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachListener(oldWidget.controller);
      _isInitialized = widget.controller?.value.isInitialized ?? false;
      _attachListener(widget.controller);
    }
  }

  @override
  void dispose() {
    _detachListener(widget.controller);
    super.dispose();
  }

  void _attachListener(VideoPlayerController? controller) {
    if (controller == null) return;
    if (controller.value.isInitialized) {
      _isInitialized = true;
      return;
    }
    _listener = () {
      if (controller.value.isInitialized && !_isInitialized && mounted) {
        setState(() => _isInitialized = true);
      }
    };
    controller.addListener(_listener!);
  }

  void _detachListener(VideoPlayerController? controller) {
    if (controller == null || _listener == null) return;
    controller.removeListener(_listener!);
    _listener = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null &&
              _isInitialized &&
              !controller.value.hasError)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
          AnimatedOpacity(
            opacity: _isInitialized ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 80),
            child: CachedNetworkImage(
              imageUrl: widget.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          ),
          if (widget.showLoading && !_isInitialized)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class _BufferingBanner extends StatelessWidget {
  const _BufferingBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 96),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainer.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Reconnecting...', style: theme.textTheme.labelMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    final shadow = Theme.of(context).colorScheme.shadow;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            shadow.withValues(alpha: 0.54),
            shadow.withValues(alpha: 0.87),
          ],
          stops: const [0.5, 0.75, 1.0],
        ),
      ),
    );
  }
}
