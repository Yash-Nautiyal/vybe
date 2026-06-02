import 'package:flutter/material.dart';

import 'popup_arrow_side.dart';
import 'popup_dropdown_painter.dart';

export 'popup_arrow_side.dart' show PopupArrowSide;

/// Visual style of the popup: card (solid + shadow) or dropdown (gradient, same as [CustomDropdownPainter]).
enum PopupStyle { card, dropdown }

class ResponsivePopupContainer extends StatelessWidget {
  final Widget child;
  final double width;

  /// If set, draws an arrow on this edge pointing toward the anchor.
  final PopupArrowSide? arrowSide;

  /// Position along the arrow edge (0.0 = start, 1.0 = end). Not necessarily center.
  final double arrowOffset;

  /// If set, uses this color for the arrow; otherwise uses [ThemeData.cardColor].
  final Color? arrowColor;

  /// Style: [PopupStyle.card] (default) or [PopupStyle.dropdown] (gradient like dropdown).
  final PopupStyle style;

  const ResponsivePopupContainer({
    super.key,
    required this.child,
    this.width = 180,
    this.arrowSide,
    this.arrowOffset = 0.5,
    this.arrowColor,
    this.style = PopupStyle.card,
  });

  static const double _arrowSize = 10;
  static const double _dropdownArrowHeight = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasArrow = arrowSide != null;

    if (style == PopupStyle.dropdown && hasArrow) {
      return Material(
        color: Colors.transparent,
        child: _buildDropdownStyle(theme),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (hasArrow) _buildArrowShadow(theme),
          Container(
            width: width,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12,
                  offset: Offset(0, 6),
                  color: Colors.black26,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  theme.brightness == Brightness.dark
                      ? const Color.fromARGB(255, 84, 47, 45)
                      : const Color.fromARGB(255, 254, 237, 221),
                  theme.brightness == Brightness.dark
                      ? const Color.fromARGB(255, 27, 30, 39)
                      : const Color.fromARGB(255, 251, 251, 251),
                  theme.brightness == Brightness.dark
                      ? const Color.fromARGB(255, 27, 30, 39)
                      : const Color.fromARGB(255, 251, 251, 251),
                  theme.brightness == Brightness.dark
                      ? const Color.fromARGB(255, 33, 70, 80)
                      : const Color.fromARGB(255, 225, 255, 255),
                ],
                stops: theme.brightness == Brightness.dark
                    ? [0.0, .17, .834, 1]
                    : [0.05, 0.3, .7, 0.99],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: child,
            ),
          ),
          if (hasArrow) _buildArrow(theme),
        ],
      ),
    );
  }

  Widget _buildDropdownStyle(ThemeData theme) {
    EdgeInsets padding = EdgeInsets.zero;
    switch (arrowSide!) {
      case PopupArrowSide.top:
        padding = const EdgeInsets.only(top: _dropdownArrowHeight);
        break;
      case PopupArrowSide.bottom:
        padding = const EdgeInsets.only(bottom: _dropdownArrowHeight);
        break;
      case PopupArrowSide.left:
        padding = const EdgeInsets.only(left: _dropdownArrowHeight);
        break;
      case PopupArrowSide.right:
        padding = const EdgeInsets.only(right: _dropdownArrowHeight);
        break;
    }
    return CustomPaint(
      painter: PopupDropdownStylePainter(
        theme: theme,
        arrowSide: arrowSide!,
        arrowOffset: arrowOffset,
        arrowColor: arrowColor,
      ),
      child: Padding(
        padding: padding,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: width - padding.left - padding.right,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildArrowShadow(ThemeData theme) {
    final color = arrowColor ?? theme.cardColor;
    const strip = _arrowSize * 2.0;
    switch (arrowSide!) {
      case PopupArrowSide.bottom:
        return Positioned(
          left: 0,
          right: 0,
          bottom: -_arrowSize,
          height: strip,
          child: CustomPaint(
            size: Size(width, strip),
            painter: _PopupArrowPainter(
              side: PopupArrowSide.bottom,
              offset: arrowOffset,
              color: color,
              shadowColor: Colors.black26,
              shadowOnly: true,
            ),
          ),
        );
      case PopupArrowSide.top:
        return Positioned(
          left: 0,
          right: 0,
          top: -_arrowSize,
          height: strip,
          child: CustomPaint(
            size: Size(width, strip),
            painter: _PopupArrowPainter(
              side: PopupArrowSide.top,
              offset: arrowOffset,
              color: color,
              shadowColor: Colors.black26,
              shadowOnly: true,
            ),
          ),
        );
      case PopupArrowSide.right:
        return Positioned(
          top: 0,
          bottom: 0,
          right: -_arrowSize,
          width: strip,
          child: CustomPaint(
            size: Size(strip, width),
            painter: _PopupArrowPainter(
              side: PopupArrowSide.right,
              offset: arrowOffset,
              color: color,
              shadowColor: Colors.black26,
              shadowOnly: true,
            ),
          ),
        );
      case PopupArrowSide.left:
        return Positioned(
          top: 0,
          bottom: 0,
          left: -_arrowSize,
          width: strip,
          child: CustomPaint(
            size: Size(strip, width),
            painter: _PopupArrowPainter(
              side: PopupArrowSide.left,
              offset: arrowOffset,
              color: color,
              shadowColor: Colors.black26,
              shadowOnly: true,
            ),
          ),
        );
    }
  }

  Widget _buildArrow(ThemeData theme) {
    final color = arrowColor ?? theme.cardColor;
    const strip = _arrowSize * 2.0;
    switch (arrowSide!) {
      case PopupArrowSide.bottom:
        return Positioned(
          left: 0,
          right: 0,
          bottom: -_arrowSize,
          height: strip,
          child: CustomPaint(
            size: Size(width, strip),
            painter: _PopupArrowPainter(
              side: PopupArrowSide.bottom,
              offset: arrowOffset,
              color: color,
              shadowColor: Colors.black26,
              shadowOnly: false,
            ),
          ),
        );
      case PopupArrowSide.top:
        return Positioned(
          left: 0,
          right: 0,
          top: -_arrowSize,
          height: strip,
          child: CustomPaint(
            size: Size(width, strip),
            painter: _PopupArrowPainter(
              side: PopupArrowSide.top,
              offset: arrowOffset,
              color: color,
              shadowColor: Colors.black26,
              shadowOnly: false,
            ),
          ),
        );
      case PopupArrowSide.right:
        return Positioned(
          top: 0,
          bottom: 0,
          right: -_arrowSize,
          width: strip,
          child: CustomPaint(
            size: Size(strip, width),
            painter: _PopupArrowPainter(
              side: PopupArrowSide.right,
              offset: arrowOffset,
              color: color,
              shadowColor: Colors.black26,
              shadowOnly: false,
            ),
          ),
        );
      case PopupArrowSide.left:
        return Positioned(
          top: 0,
          bottom: 0,
          left: -_arrowSize,
          width: strip,
          child: CustomPaint(
            size: Size(strip, width),
            painter: _PopupArrowPainter(
              side: PopupArrowSide.left,
              offset: arrowOffset,
              color: color,
              shadowColor: Colors.black26,
              shadowOnly: false,
            ),
          ),
        );
    }
  }
}

class _PopupArrowPainter extends CustomPainter {
  final PopupArrowSide side;
  final double offset;
  final Color color;
  final Color shadowColor;
  final bool shadowOnly;

  _PopupArrowPainter({
    required this.side,
    required this.offset,
    required this.color,
    required this.shadowColor,
    this.shadowOnly = false,
  });

  static const double _arrowSize = 10;
  static const double _inset = 12;

  @override
  void paint(Canvas canvas, Size size) {
    // Strip size: for bottom/top (width x strip), for left/right (strip x height).
    final centerX = _inset +
        (size.width - _inset * 2 - _arrowSize * 2).clamp(0.0, double.infinity) *
            offset;
    final centerY = _inset +
        (size.height - _inset * 2 - _arrowSize * 2)
                .clamp(0.0, double.infinity) *
            offset;

    Offset tip;
    List<Offset> triangle;
    switch (side) {
      case PopupArrowSide.bottom:
        tip = Offset(centerX + _arrowSize, size.height);
        triangle = [
          tip,
          Offset(tip.dx - _arrowSize, tip.dy - _arrowSize),
          Offset(tip.dx + _arrowSize, tip.dy - _arrowSize),
        ];
        break;
      case PopupArrowSide.top:
        tip = Offset(centerX + _arrowSize, 0);
        triangle = [
          tip,
          Offset(tip.dx - _arrowSize, tip.dy + _arrowSize),
          Offset(tip.dx + _arrowSize, tip.dy + _arrowSize),
        ];
        break;
      case PopupArrowSide.right:
        tip = Offset(size.width, centerY + _arrowSize);
        triangle = [
          tip,
          Offset(tip.dx - _arrowSize, tip.dy - _arrowSize),
          Offset(tip.dx - _arrowSize, tip.dy + _arrowSize),
        ];
        break;
      case PopupArrowSide.left:
        tip = Offset(0, centerY + _arrowSize);
        triangle = [
          tip,
          Offset(tip.dx + _arrowSize, tip.dy - _arrowSize),
          Offset(tip.dx + _arrowSize, tip.dy + _arrowSize),
        ];
        break;
    }

    final path = Path()..addPolygon(triangle, true);

    if (shadowOnly) {
      canvas.save();
      canvas.translate(2, 4);
      canvas.drawPath(path, Paint()..color = shadowColor.withOpacity(0.05));
      canvas.restore();
    } else {
      canvas.drawPath(path, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _PopupArrowPainter old) =>
      old.side != side ||
      old.offset != offset ||
      old.color != color ||
      old.shadowOnly != shadowOnly;
}
