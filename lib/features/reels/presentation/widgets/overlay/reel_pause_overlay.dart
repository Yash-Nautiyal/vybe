import 'package:flutter/material.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: const Padding(
            padding: EdgeInsets.all(22),
            child: Icon(Icons.pause_rounded, size: 56, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
