import 'package:flutter/material.dart';

enum SnackbarType { error, success }

class AnimatedSnackbar extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final VoidCallback onDismiss;

  const AnimatedSnackbar({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<AnimatedSnackbar> createState() => _AnimatedSnackbarState();
}

class _AnimatedSnackbarState extends State<AnimatedSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDisposed = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1.5), // Start from below screen
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    // Auto dismiss after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      if (!_isDisposed) {
        // Add this check
        _dismissSnackbar();
      }
    });
  }

  void _dismissSnackbar() {
    if (!_isDisposed) {
      // Add this check
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // Set the flag to true
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get colors and icon based on type
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (widget.type) {
      case SnackbarType.error:
        backgroundColor = Colors.red.shade600;
        iconColor = Colors.white;
        icon = Icons.error_outline;
        break;
      case SnackbarType.success:
        backgroundColor = Colors.green.shade600;
        iconColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: iconColor, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _dismissSnackbar,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            'Dismiss',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void showAnimatedSnackbar(
  BuildContext context,
  String message,
  SnackbarType type, {
  OverlayState? overlayState,
}
) {
  final resolvedOverlay =
      overlayState ??
      Overlay.maybeOf(context, rootOverlay: true) ??
      Navigator.maybeOf(context, rootNavigator: true)?.overlay;
  if (resolvedOverlay == null) return;

  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder:
        (context) => AnimatedSnackbar(
          message: message,
          type: type,
          onDismiss: () {
            overlayEntry?.remove();
          },
        ),
  );

  resolvedOverlay.insert(overlayEntry);
}
