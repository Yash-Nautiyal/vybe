import 'package:flutter/material.dart';

class AnimatedToggleButton extends StatefulWidget {
  final List<String> values;
  final ValueChanged<int> onToggle;
  final ThemeData theme;
  final int initialIndex;

  const AnimatedToggleButton({
    super.key,
    required this.values,
    required this.onToggle,
    required this.theme,
    this.initialIndex = 0,
  }) : assert(
         values.length == 2,
         'AnimatedToggleButton only supports two values',
       );

  @override
  State<AnimatedToggleButton> createState() => _AnimatedToggleButtonState();
}

class _AnimatedToggleButtonState extends State<AnimatedToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _animation;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (_selectedIndex == 1) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onToggle(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
      widget.onToggle(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.theme.dividerColor.withAlpha(100)),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 30,
            margin: EdgeInsets.only(left: _selectedIndex == 0 ? 0 : 60),
            decoration: BoxDecoration(
              color: widget.theme.disabledColor.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.values.length,
              (index) => InkWell(
                onTap: () => _onToggle(index),
                child: Container(
                  width: 60,
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    widget.values[index],
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      color:
                          _selectedIndex == index
                              ? widget.theme.colorScheme.tertiary
                              : widget.theme.disabledColor,
                      fontWeight:
                          _selectedIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
