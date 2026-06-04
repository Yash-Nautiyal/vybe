import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vybe/core/constants/app_icons.dart';

enum ActionButtonType { like, comment, share, star }

class ActionButton extends StatefulWidget {
  const ActionButton.like({
    super.key,
    required this.liked,
    required this.label,
    this.onClick,
  }) : type = ActionButtonType.like,
       icon = liked == true ? AppIcons.heartBoldIcon : AppIcons.heartLinearIcon,
       starred = null;

  const ActionButton.comment({super.key, required this.label, this.onClick})
    : type = ActionButtonType.comment,
      icon = AppIcons.chatLinearIcon,
      liked = null,
      starred = null;

  const ActionButton.share({super.key, required this.label, this.onClick})
    : type = ActionButtonType.share,
      icon = AppIcons.shareLinearIcon,
      liked = null,
      starred = null;

  const ActionButton.star({
    super.key,
    required this.label,
    required this.starred,
    this.onClick,
  }) : type = ActionButtonType.star,
       icon = starred == true ? AppIcons.starBoldIcon : AppIcons.starLinearIcon,
       liked = null;

  final String icon;
  final String label;
  final ActionButtonType type;
  final bool? liked;
  final bool? starred;
  final VoidCallback? onClick;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  static final _popSequence = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.38), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 1.38, end: 0.88), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 35),
  ]);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnim = _popSequence.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  bool get _isToggleable =>
      widget.type == ActionButtonType.like ||
      widget.type == ActionButtonType.star;

  void _playPopAnimation() {
    _controller.forward(from: 0);
  }

  void _handleTap() {
    if (_isToggleable) {
      _playPopAnimation();
    }
    final onClick = widget.onClick;
    if (onClick == null) return;

    // Defer so the pop frame renders before the bloc rebuild replaces icon state.
    WidgetsBinding.instance.addPostFrameCallback((_) => onClick());
  }

  @override
  void didUpdateWidget(covariant ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final activatedExternally =
        widget.type == ActionButtonType.like &&
        oldWidget.liked == false &&
        widget.liked == true;
    final starredExternally =
        widget.type == ActionButtonType.star &&
        oldWidget.starred == false &&
        widget.starred == true;
    if (activatedExternally || starredExternally) {
      _playPopAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _iconColor(ColorScheme colors) {
    if (widget.type == ActionButtonType.like && widget.liked == true) {
      return colors.primary;
    }
    if (widget.type == ActionButtonType.star && widget.starred == true) {
      return colors.secondary;
    }
    return colors.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final iconColor = _iconColor(colors);

    final content = Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnim,
          builder:
              (_, child) => Transform.scale(
                scale: _scaleAnim.value,
                child: child,
              ),
          child: SvgPicture.asset(
            widget.icon,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            width: 30,
            height: 30,
          ),
        ),
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color:
                widget.type == ActionButtonType.like && widget.liked == true
                    ? colors.primary
                    : null,
          ),
        ),
      ],
    );

    if (widget.onClick == null) return content;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
