import 'package:flutter/material.dart';

class BottomGradient extends StatelessWidget {
  const BottomGradient({super.key});

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
