import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:vybe/core/error/failures.dart';

import '../../domain/entities/video.dart';
import '../../presentation/bloc/reels_bloc.dart';
import '../../presentation/bloc/reels_event.dart';

import 'error/video_error_overlay.dart';
import 'overlay/reel_overlay.dart';
import 'overlay/reel_pause_overlay.dart';
import 'ui/bottom_gradient.dart';
import 'ui/buffer_banner.dart';
import 'ui/double_tap_heart.dart';

class ReelItem extends StatefulWidget {
  const ReelItem({
    super.key,
    required this.index,
    required this.video,
    this.controller,
    this.failure,
    this.isBuffering = false,
    this.isUserPaused = false,
    this.canTogglePlayPause = false,
    this.onRetry,
  });

  final int index;
  final Video video;
  final VideoPlayerController? controller;
  final AppFailure? failure;
  final bool isBuffering;
  final bool isUserPaused;
  final bool canTogglePlayPause;
  final VoidCallback? onRetry;

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _descExpandedNotifier = ValueNotifier(false);

  late final AnimationController _heartController;
  late final Animation<double> _heartScale;
  late final Animation<double> _heartOpacity;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
    );
    _heartOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 45),
    ]).animate(_heartController);
  }

  @override
  void dispose() {
    _heartController.dispose();
    _descExpandedNotifier.dispose();
    super.dispose();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    setState(() => _tapPosition = details.localPosition);
  }

  void _onDoubleTap() {
    if (!widget.video.liked) {
      context.read<ReelsBloc>().add(ReelLikeToggled(widget.video.id));
    }
    _heartController.forward(from: 0);
  }

  void _onTap() {
    if (!widget.canTogglePlayPause) return;
    context.read<ReelsBloc>().add(ReelPlayPauseToggled(widget.index));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _VideoBackground(
            controller: widget.controller,
            thumbnailUrl: widget.video.thumbnailUrl,
            showLoading: widget.failure == null,
          ),
          if (widget.failure != null)
            VideoErrorOverlay(
              failure: widget.failure!,
              onRetry: widget.onRetry,
            ),
          const BottomGradient(),

          ValueListenableBuilder<bool>(
            valueListenable: _descExpandedNotifier,
            builder:
                (context, expanded, _) => AnimatedOpacity(
                  opacity: expanded ? 0.45 : 0.0,
                  duration: const Duration(milliseconds: 340),
                  curve: Curves.easeInOutCubic,
                  child: const ColoredBox(
                    color: Colors.black,
                    child: SizedBox.expand(),
                  ),
                ),
          ),

          ReelOverlay(
            video: widget.video,
            expandedNotifier: _descExpandedNotifier,
          ),
          if (widget.isBuffering && widget.failure == null)
            const BufferingBanner(),

          if (widget.isUserPaused &&
              widget.failure == null &&
              !widget.isBuffering)
            const PauseOverlay(),

          if (_tapPosition != null)
            DoubleTapHeart(
              position: _tapPosition!,
              controller: _heartController,
              scaleAnim: _heartScale,
              opacityAnim: _heartOpacity,
            ),
        ],
      ),
    );
  }
}

// MARK: Video Background

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
