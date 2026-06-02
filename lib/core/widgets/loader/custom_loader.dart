import 'package:flutter/material.dart';

class CustomLoader extends StatefulWidget {
  final double size;
  final double borderWidth;
  final double gap;
  final Duration animationDuration;
  final double borderRadius;

  const CustomLoader({
    super.key,
    this.size = 130.0,
    this.borderWidth = 3,
    this.gap = 15.0,
    this.animationDuration = const Duration(seconds: 2),
    this.borderRadius = 25.0,
  });

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with TickerProviderStateMixin {
  late AnimationController _outerController;
  late AnimationController _innerController;
  late AnimationController _dimmingController;
  late Animation<double> _outerAnimation;
  late Animation<double> _innerAnimation;
  // late Animation<double> _dimmingAnimation;

  @override
  void initState() {
    super.initState();

    // Outer container animation (clockwise)
    _outerController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _outerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _outerController, curve: Curves.linear));

    // Inner container animation (counter-clockwise)
    _innerController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _innerAnimation = Tween<double>(
      begin: 0.0,
      end: -1.0, // Negative for counter-clockwise
    ).animate(CurvedAnimation(parent: _innerController, curve: Curves.linear));

    // Dimming animation for logo (pulsing effect)
    _dimmingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // _dimmingAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
    //   CurvedAnimation(parent: _dimmingController, curve: Curves.easeInOut),
    // );

    // Start all animations
    _outerController.repeat();
    _innerController.repeat();
    _dimmingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _outerController.dispose();
    _innerController.dispose();
    _dimmingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating border
          AnimatedBuilder(
            animation: _outerAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle:
                    _outerAnimation.value * 2 * 3.14159, // 2π for full rotation
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: theme.indicatorColor.withAlpha(50),
                      width: widget.borderWidth,
                    ),
                  ),
                ),
              );
            },
          ),

          // Inner rotating border
          AnimatedBuilder(
            animation: _innerAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle:
                    _innerAnimation.value * 2 * 3.14159, // 2π for full rotation
                child: Container(
                  width: widget.size - (widget.gap * 1.7),
                  height: widget.size - (widget.gap * 1.7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: theme.indicatorColor.withAlpha(100),
                      width: widget.borderWidth + 5.5,
                    ),
                  ),
                ),
              );
            },
          ),

          // Center logo with dimming effect
          // AnimatedBuilder(
          //   animation: _dimmingAnimation,
          //   builder: (context, child) {
          //     return AnimatedOpacity(
          //       opacity: _dimmingAnimation.value,
          //       duration: const Duration(milliseconds: 100),
          //       child: Padding(
          //         padding: const EdgeInsets.all(33.0),
          //         child: Image.asset('assets/logo/2doo logo.png'),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
