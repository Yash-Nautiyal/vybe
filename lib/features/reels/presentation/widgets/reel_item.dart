import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vybe/core/error/failures.dart';
import 'package:vybe/core/theme/app_pallete.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

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
          _VideoErrorOverlay(failure: failure!, onRetry: onRetry),
        const _BottomGradient(),
        _ReelOverlay(video: video),
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
    final controller = widget.controller;

    return ColoredBox(
      color: AppPallete.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && _isInitialized && !controller.value.hasError)
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
            const Center(
              child: CircularProgressIndicator(color: AppPallete.white),
            ),
        ],
      ),
    );
  }
}

class _VideoErrorOverlay extends StatelessWidget {
  const _VideoErrorOverlay({required this.failure, this.onRetry});

  final AppFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.65),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppPallete.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  failure.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppPallete.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Tap to Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BufferingBanner extends StatelessWidget {
  const _BufferingBanner();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 96),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppPallete.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Reconnecting...',
                    style: TextStyle(
                      color: AppPallete.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54, Colors.black87],
          stops: [0.5, 0.75, 1.0],
        ),
      ),
    );
  }
}

class _ReelOverlay extends StatelessWidget {
  const _ReelOverlay({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _VideoInfo(video: video)),
                const SizedBox(width: 16),
                _SideActions(likes: video.likes, comments: video.comments),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoInfo extends StatelessWidget {
  const _VideoInfo({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppPallete.grey700,
              backgroundImage: CachedNetworkImageProvider(video.userProfilePic),
            ),
            const SizedBox(width: 10),
            Text(
              video.username,
              style: const TextStyle(
                color: AppPallete.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          video.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppPallete.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SideActions extends StatelessWidget {
  const _SideActions({required this.likes, required this.comments});

  final int likes;
  final int comments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionButton(icon: Icons.favorite, label: _formatCount(likes)),
        const SizedBox(height: 20),
        _ActionButton(icon: Icons.chat_bubble, label: _formatCount(comments)),
        const SizedBox(height: 20),
        const _ActionButton(icon: Icons.share, label: 'Share'),
      ],
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppPallete.white, size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppPallete.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
