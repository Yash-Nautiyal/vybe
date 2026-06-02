
import 'package:flutter/material.dart';

import 'responsive_popup.dart';
import 'responsive_popup_container.dart';

class Popup extends StatefulWidget {
  final GlobalKey popupAnchorKey;
  final LayerLink layerLink;
  final ResponsivePopupController popupController;
  final Widget icon;
  final List<Widget> items;
  final PopupPreferredPosition preferredPosition;
  final Offset manualOffset;
  final double? arrowOffset;
  final double width;

  /// If set, uses this color for the arrow; otherwise uses [ThemeData.cardColor].
  final Color? arrowColor;

  const Popup({
    super.key,
    required this.popupAnchorKey,
    required this.layerLink,
    required this.popupController,
    required this.icon,
    required this.items,
    this.preferredPosition = PopupPreferredPosition.auto,
    this.manualOffset = const Offset(0, 8),
    this.arrowOffset,
    this.width = 130,
    this.arrowColor,
  });

  @override
  State<Popup> createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: widget.popupAnchorKey,
      link: widget.layerLink,
      child: IconButton(
        icon: widget.icon,
        onPressed: () {
          widget.popupController.show(
            context: context,
            link: widget.layerLink,
            anchorKey: widget.popupAnchorKey,
            preferredPosition: widget.preferredPosition,
            manualOffset: widget.manualOffset,
            popupWidth: widget.width,
            childBuilder: (placement) => ResponsivePopupContainer(
              width: widget.width,
              arrowSide: placement.arrowSide,
              arrowOffset: widget.arrowOffset ?? placement.arrowOffset,
              arrowColor: widget.arrowColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...widget.items,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
