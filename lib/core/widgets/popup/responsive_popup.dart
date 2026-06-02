import 'package:flutter/material.dart';

import 'popup_arrow_side.dart';
import 'responsive_popup_container.dart';

/// Preferred side to open the popup relative to the anchor.
enum PopupPreferredPosition { left, right, top, bottom, auto }

/// Placement for the popup when using [ResponsivePopupController.show] with
/// [preferredPosition] or [childBuilder].
class PopupPlacement {
  const PopupPlacement({
    required this.offset,
    required this.arrowSide,
    this.arrowOffset = 0.5,
  });

  final Offset offset;
  final PopupArrowSide arrowSide;

  /// Position along the arrow edge (0.0 = start, 1.0 = end). Not necessarily center.
  final double arrowOffset;
}

class ResponsivePopupController {
  OverlayEntry? _entry;
  void Function()? _exitAnimationCallback;

  bool get isShowing => _entry != null;

  /// Called by the overlay to remove the entry (e.g. after exit animation).
  void removeEntry() {
    _entry?.remove();
    _entry = null;
    _exitAnimationCallback = null;
  }

  /// Registers a callback to run when [hide] is called (e.g. play exit animation then [removeEntry]).
  void registerExit(void Function() animateOut) {
    _exitAnimationCallback = animateOut;
  }

  static const double _popupWidth = 180;
  static const double _popupHeight = 100;
  static const double _gap = 8;

  /// Shows the popup.
  ///
  /// - [preferredPosition]: open on left, right, top, bottom, or [PopupPreferredPosition.auto].
  /// - [manualOffset]: delta added to the computed offset (e.g. to nudge position).
  /// - [popupWidth]: if set, used for placement centering (should match the actual popup width).
  /// - [arrowOffsetOverride]: when non-null, used instead of computed arrow alignment (0.0–1.0).
  /// - When [anchorKey] and [childBuilder] are provided, placement is computed from [preferredPosition].
  void show({
    required BuildContext context,
    required LayerLink link,
    Widget? child,
    Widget Function(PopupPlacement placement)? childBuilder,
    Offset offset = const Offset(0, 8),
    PopupPreferredPosition preferredPosition = PopupPreferredPosition.auto,
    Offset? manualOffset,
    double? popupWidth,
    double? arrowOffsetOverride,
    GlobalKey? anchorKey,
  }) {
    hide();

    final usePlacement = anchorKey != null && childBuilder != null;
    Offset finalOffset = offset;
    Widget finalChild;
    PopupArrowSide arrowSide = PopupArrowSide.bottom;

    if (usePlacement) {
      final key = anchorKey;
      final placement = _computePlacement(
        context,
        key,
        preferredPosition,
        manualOffset ?? Offset.zero,
        arrowOffsetOverride,
        popupWidth: popupWidth,
      );
      if (placement != null) {
        finalOffset = placement.offset;
        arrowSide = placement.arrowSide;
        finalChild = childBuilder(placement);
      } else {
        arrowSide = _arrowSideForPosition(preferredPosition);
        finalChild = childBuilder(PopupPlacement(
          offset: offset + (manualOffset ?? Offset.zero),
          arrowSide: arrowSide,
          arrowOffset: arrowOffsetOverride ?? 0.5,
        ));
      }
    } else if (childBuilder != null) {
      arrowSide = _arrowSideForPosition(preferredPosition);
      final placement = PopupPlacement(
        offset: offset + (manualOffset ?? Offset.zero),
        arrowSide: arrowSide,
        arrowOffset: arrowOffsetOverride ?? 0.5,
      );
      finalChild = childBuilder(placement);
    } else {
      finalChild = child ?? const SizedBox.shrink();
    }

    _entry = OverlayEntry(
      builder: (_) => _AnimatedPopupOverlay(
        controller: this,
        link: link,
        offset: finalOffset,
        arrowSide: arrowSide,
        child: finalChild,
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  PopupArrowSide _arrowSideForPosition(PopupPreferredPosition pos) {
    switch (pos) {
      case PopupPreferredPosition.top:
        return PopupArrowSide.bottom;
      case PopupPreferredPosition.bottom:
        return PopupArrowSide.top;
      case PopupPreferredPosition.left:
        return PopupArrowSide.right;
      case PopupPreferredPosition.right:
        return PopupArrowSide.left;
      case PopupPreferredPosition.auto:
        return PopupArrowSide.bottom;
    }
  }

  PopupPlacement? _computePlacement(
    BuildContext context,
    GlobalKey anchorKey,
    PopupPreferredPosition preferredPosition,
    Offset manualOffset,
    double? arrowOffsetOverride, {
    double? popupWidth,
  }) {
    final effectiveWidth = popupWidth ?? _popupWidth;
    final anchorContext = anchorKey.currentContext;
    if (anchorContext == null) return null;

    final anchorBox = anchorContext.findRenderObject() as RenderBox?;
    if (anchorBox == null || !anchorBox.hasSize) return null;

    final screenSize = MediaQuery.sizeOf(context);
    final anchorPos = anchorBox.localToGlobal(Offset.zero);
    final anchorSize = anchorBox.size;

    final spaceAbove = anchorPos.dy;
    final spaceBelow = screenSize.height - (anchorPos.dy + anchorSize.height);
    final spaceLeft = anchorPos.dx;
    final spaceRight = screenSize.width - (anchorPos.dx + anchorSize.width);

    double dx = 0;
    double dy = 0;
    PopupArrowSide arrowSide = PopupArrowSide.bottom;
    double arrowOffset = 0.5;

    void applyManualOffset() {
      dx += manualOffset.dx;
      dy += manualOffset.dy;
      dx = dx.clamp(
        -anchorPos.dx,
        screenSize.width - anchorPos.dx - effectiveWidth,
      );
      dy = dy.clamp(
        -anchorPos.dy,
        screenSize.height - anchorPos.dy - _popupHeight,
      );
    }

    switch (preferredPosition) {
      case PopupPreferredPosition.auto:
        {
          final above = spaceAbove >= _popupHeight + _gap;
          final below = spaceBelow >= _popupHeight + _gap;
          final left = spaceLeft >= _popupWidth + _gap;
          final right = spaceRight >= _popupWidth + _gap;
          double bestScore = -double.infinity;
          PopupArrowSide? bestSide;
          double? bestDx;
          double? bestDy;
          double? bestArrowOffset;
          if (above && spaceAbove > bestScore) {
            bestScore = spaceAbove;
            bestSide = PopupArrowSide.bottom;
            bestDy = -_popupHeight - _gap;
            final preferredDx = anchorSize.width / 2 - effectiveWidth / 2;
            bestDx = preferredDx.clamp(
              -anchorPos.dx,
              screenSize.width - anchorPos.dx - effectiveWidth,
            );
            bestArrowOffset = ((anchorSize.width / 2 - bestDx) / effectiveWidth)
                .clamp(0.0, 1.0);
          }
          if (below && spaceBelow > bestScore) {
            bestScore = spaceBelow;
            bestSide = PopupArrowSide.top;
            bestDy = anchorSize.height + _gap;
            final preferredDx = anchorSize.width / 2 - effectiveWidth / 2;
            bestDx = preferredDx.clamp(
              -anchorPos.dx,
              screenSize.width - anchorPos.dx - effectiveWidth,
            );
            bestArrowOffset = ((anchorSize.width / 2 - bestDx) / effectiveWidth)
                .clamp(0.0, 1.0);
          }
          if (left && spaceLeft > bestScore) {
            bestScore = spaceLeft;
            bestSide = PopupArrowSide.right;
            bestDx = -effectiveWidth - _gap;
            final preferredDy = anchorSize.height / 2 - _popupHeight / 2;
            bestDy = preferredDy.clamp(
              -anchorPos.dy,
              screenSize.height - anchorPos.dy - _popupHeight,
            );
            bestArrowOffset = ((anchorSize.height / 2 - bestDy) / _popupHeight)
                .clamp(0.0, 1.0);
          }
          if (right && spaceRight > bestScore) {
            bestScore = spaceRight;
            bestSide = PopupArrowSide.left;
            bestDx = anchorSize.width + _gap;
            final preferredDy = anchorSize.height / 2 - _popupHeight / 2;
            bestDy = preferredDy.clamp(
              -anchorPos.dy,
              screenSize.height - anchorPos.dy - _popupHeight,
            );
            bestArrowOffset = ((anchorSize.height / 2 - bestDy) / _popupHeight)
                .clamp(0.0, 1.0);
          }
          if (bestSide != null && bestDx != null && bestDy != null) {
            dx = bestDx;
            dy = bestDy;
            arrowSide = bestSide;
            arrowOffset =
                (arrowOffsetOverride ?? bestArrowOffset ?? 0.5).clamp(0.0, 1.0);
            applyManualOffset();
            return PopupPlacement(
              offset: Offset(dx, dy),
              arrowSide: arrowSide,
              arrowOffset: arrowOffset,
            );
          }
          dx = anchorSize.width / 2 - effectiveWidth / 2;
          dy = -_popupHeight - _gap;
          arrowSide = PopupArrowSide.bottom;
          arrowOffset = arrowOffsetOverride ?? 0.5;
          applyManualOffset();
          return PopupPlacement(
            offset: Offset(dx, dy),
            arrowSide: arrowSide,
            arrowOffset: arrowOffset.clamp(0.0, 1.0),
          );
        }

      case PopupPreferredPosition.top:
        dy = -_popupHeight - _gap;
        arrowSide = PopupArrowSide.bottom;
        final preferredDx = anchorSize.width / 2 - effectiveWidth / 2;
        dx = preferredDx.clamp(
          -anchorPos.dx,
          screenSize.width - anchorPos.dx - effectiveWidth,
        );
        arrowOffset =
            ((anchorSize.width / 2 - dx) / effectiveWidth).clamp(0.0, 1.0);
        applyManualOffset();
        break;
      case PopupPreferredPosition.bottom:
        dy = anchorSize.height + _gap;
        arrowSide = PopupArrowSide.top;
        final preferredDxB = anchorSize.width / 2 - effectiveWidth / 2;
        dx = preferredDxB.clamp(
          -anchorPos.dx,
          screenSize.width - anchorPos.dx - effectiveWidth,
        );
        arrowOffset =
            ((anchorSize.width / 2 - dx) / effectiveWidth).clamp(0.0, 1.0);
        applyManualOffset();
        break;
      case PopupPreferredPosition.left:
        dx = -effectiveWidth - _gap;
        arrowSide = PopupArrowSide.right;
        final preferredDyL = anchorSize.height / 2 - _popupHeight / 2;
        dy = preferredDyL.clamp(
          -anchorPos.dy,
          screenSize.height - anchorPos.dy - _popupHeight,
        );
        arrowOffset =
            ((anchorSize.height / 2 - dy) / _popupHeight).clamp(0.0, 1.0);
        applyManualOffset();
        break;
      case PopupPreferredPosition.right:
        dx = anchorSize.width + _gap;
        arrowSide = PopupArrowSide.left;
        final preferredDyR = anchorSize.height / 2 - _popupHeight / 2;
        dy = preferredDyR.clamp(
          -anchorPos.dy,
          screenSize.height - anchorPos.dy - _popupHeight,
        );
        arrowOffset =
            ((anchorSize.height / 2 - dy) / _popupHeight).clamp(0.0, 1.0);
        applyManualOffset();
        break;
    }

    if (arrowOffsetOverride != null) {
      arrowOffset = arrowOffsetOverride.clamp(0.0, 1.0);
    }
    return PopupPlacement(
      offset: Offset(dx, dy),
      arrowSide: arrowSide,
      arrowOffset: arrowOffset,
    );
  }

  void hide() {
    if (_exitAnimationCallback != null) {
      _exitAnimationCallback!();
      _exitAnimationCallback = null;
    } else {
      removeEntry();
    }
  }

  void dispose() {
    hide();
  }
}

/// Overlay that runs slide-from-arrow + fade in on show and slide-toward-arrow + fade out when closed.
class _AnimatedPopupOverlay extends StatefulWidget {
  const _AnimatedPopupOverlay({
    required this.controller,
    required this.link,
    required this.offset,
    required this.arrowSide,
    required this.child,
  });

  final ResponsivePopupController controller;
  final LayerLink link;
  final Offset offset;
  final PopupArrowSide arrowSide;
  final Widget child;

  @override
  State<_AnimatedPopupOverlay> createState() => _AnimatedPopupOverlayState();
}

class _AnimatedPopupOverlayState extends State<_AnimatedPopupOverlay>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 200);
  static const double _slideDistance = 14;
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween<Offset>(
      begin: _slideBeginForArrowSide(widget.arrowSide),
      end: Offset.zero,
    ).animate(curve);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    widget.controller.registerExit(_animateOut);
    _controller.forward();
  }

  /// From the arrow (anchor) toward the side the popup opens. e.g. opens on left → right-to-left.
  static Offset _slideBeginForArrowSide(PopupArrowSide side) {
    switch (side) {
      case PopupArrowSide.bottom:
        return const Offset(0, _slideDistance);
      case PopupArrowSide.top:
        return const Offset(0, -_slideDistance);
      case PopupArrowSide.left:
        return const Offset(-_slideDistance, 0);
      case PopupArrowSide.right:
        return const Offset(_slideDistance, 0);
    }
  }

  void _animateOut() {
    if (!_controller.isAnimating && _controller.value > 0) {
      _controller.reverse().then((_) {
        if (mounted) widget.controller.removeEntry();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _animateOut,
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: widget.link,
              offset: widget.offset,
              showWhenUnlinked: false,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacity.value,
                    child: Transform.translate(
                      offset: _slide.value,
                      child: child,
                    ),
                  );
                },
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
