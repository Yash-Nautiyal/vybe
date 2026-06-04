import 'package:flutter/material.dart';

import 'app_connectivity_bar.dart';

class AppConnectivityOverlay extends StatelessWidget {
  const AppConnectivityOverlay({
    super.key,
    required this.barMode,
    required this.child,
  });

  final ConnectivityBarMode barMode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppConnectivityBar(mode: barMode),
        ),
      ],
    );
  }
}
