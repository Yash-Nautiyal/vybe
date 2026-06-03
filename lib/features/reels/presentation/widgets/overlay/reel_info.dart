import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vybe/core/helpers/date_time_helper.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

class ReelInfo extends StatefulWidget {
  const ReelInfo({
    super.key,
    required this.video,
    required this.expandedNotifier,
  });

  final Video video;
  final ValueNotifier<bool> expandedNotifier;

  @override
  State<ReelInfo> createState() => _ReelInfoState();
}

class _ReelInfoState extends State<ReelInfo> {
  static const double _collapsedHeight = 66.0;
  static const double _expandedHeight = 220.0;
  static const Duration _dur = Duration(milliseconds: 340);
  static const Curve _curve = Curves.easeInOutCubic;

  bool _expanded = false;
  final ScrollController _scroll = ScrollController();

  @override
  void didUpdateWidget(covariant ReelInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video != widget.video && _expanded) _close();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _open() {
    setState(() => _expanded = true);
    widget.expandedNotifier.value = true;
  }

  void _close() {
    setState(() => _expanded = false);
    widget.expandedNotifier.value = false;
    _scroll.jumpTo(0);
  }

  void _toggle() => _expanded ? _close() : _open();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.outline,
              backgroundImage: CachedNetworkImageProvider(
                widget.video.userProfilePic,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.video.username,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: AnimatedSize(
            duration: _dur,
            curve: _curve,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              height: _expanded ? _expandedHeight : _collapsedHeight,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scroll,
                      physics:
                          _expanded
                              ? const ClampingScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                      child: Text(
                        widget.video.description,
                        style: theme.textTheme.bodyLarge,
                        maxLines: _expanded ? null : 2,
                        overflow: _expanded ? null : TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (_expanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        formatRelativeTime(widget.video.createdAt!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
