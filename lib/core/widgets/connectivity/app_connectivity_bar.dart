import 'package:flutter/material.dart';

import '../../error/messages/execption_messages.dart';

enum ConnectivityBarMode { hidden, offline, reconnected }

class AppConnectivityBar extends StatefulWidget {
  const AppConnectivityBar({super.key, required this.mode});

  final ConnectivityBarMode mode;

  @override
  State<AppConnectivityBar> createState() => _AppConnectivityBarState();
}

class _AppConnectivityBarState extends State<AppConnectivityBar> {
  static const _animationDuration = Duration(milliseconds: 400);
  static const _animationCurve = Curves.easeOutCubic;

  /// Drives slide/opacity — can hide before [ _styleMode ] updates.
  bool _visible = false;

  /// Drives colors/text — kept until the hide animation finishes.
  ConnectivityBarMode _styleMode = ConnectivityBarMode.hidden;

  @override
  void initState() {
    super.initState();
    _applyMode(widget.mode, animate: false);
  }

  @override
  void didUpdateWidget(AppConnectivityBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _applyMode(widget.mode);
    }
  }

  void _applyMode(ConnectivityBarMode mode, {bool animate = true}) {
    if (mode != ConnectivityBarMode.hidden) {
      setState(() {
        _styleMode = mode;
        _visible = true;
      });
      return;
    }

    if (!_visible) return;

    setState(() => _visible = false);

    if (!animate) return;

    final styleWhenHiding = _styleMode;
    Future.delayed(_animationDuration, () {
      if (!mounted) return;
      if (widget.mode != ConnectivityBarMode.hidden) return;
      if (_styleMode != styleWhenHiding) return;
      setState(() => _styleMode = ConnectivityBarMode.hidden);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isReconnected = _styleMode == ConnectivityBarMode.reconnected;

    final backgroundColor =
        isReconnected
            ? const Color(0xFF2E7D32)
            : Theme.of(context).colorScheme.errorContainer;
    final foregroundColor =
        isReconnected
            ? Colors.white
            : Theme.of(context).colorScheme.onErrorContainer;

    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, -1),
      duration: _animationDuration,
      curve: _animationCurve,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: _animationDuration,
        curve: _animationCurve,
        child: Material(
          color: backgroundColor,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.35),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    isReconnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    size: 20,
                    color: foregroundColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isReconnected
                          ? AppExceptionMessages.backOnline
                          : AppExceptionMessages.noInternet,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
