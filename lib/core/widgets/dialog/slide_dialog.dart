import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_pallete.dart';

class SlideDialog extends StatefulWidget {
  final ThemeData theme;
  final Widget child;
  final String title;
  final bool isProfile;
  final VoidCallback? onRefresh;
  final Future<void> Function()? onDeleteAccount;
  final VoidCallback? onDeleteSuccess;

  const SlideDialog({
    super.key,
    required this.theme,
    required this.child,
    required this.title,
    this.isProfile = false,
    this.onRefresh,
    this.onDeleteAccount,
    this.onDeleteSuccess,
  });

  @override
  State<SlideDialog> createState() => _SlideDialogState();
}

class _SlideDialogState extends State<SlideDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  // bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _closeDialog() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: WillPopScope(
        onWillPop: () async {
          await _closeDialog();
          return false;
        },
        child: Stack(
          children: [
            GestureDetector(
              onTap: _closeDialog,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                color: Colors.transparent,
              ),
            ),
            Positioned(
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.85,
                  height: MediaQuery.sizeOf(context).height,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color.fromARGB(255, 84, 47, 45)
                                  : AppPallete.errorLighter,
                              Theme.of(context).brightness == Brightness.dark
                                  ? Color.fromARGB(
                                    255,
                                    18,
                                    21,
                                    25,
                                  ).withOpacity(.9)
                                  : const Color.fromARGB(255, 251, 251, 251),
                              Theme.of(context).brightness == Brightness.dark
                                  ? Color.fromARGB(255, 18, 21, 25)
                                  : const Color.fromARGB(255, 251, 251, 251),
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color.fromARGB(255, 46, 76, 88)
                                  : const Color.fromARGB(255, 212, 251, 251),
                            ],
                            stops:
                                widget.theme.brightness == Brightness.dark
                                    ? [0.0, .17, .86, 1]
                                    : [0.05, 0.3, .7, 0.99],
                            begin: Alignment(-1.7, 1),
                            end: Alignment(1.2, -1),
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ).copyWith(top: 10, bottom: 10),
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget.title,
                                          style:
                                              widget.theme.textTheme.titleLarge,
                                        ),
                                        const Spacer(),
                                        if (widget.onRefresh != null)
                                          IconButton(
                                            onPressed: widget.onRefresh,
                                            icon: Icon(
                                              Icons.refresh,
                                              color: widget.theme.disabledColor,
                                            ),
                                          ),
                                        // if (widget.isProfile == true)
                                        //   IconButton(
                                        //     onPressed: () {
                                        //       setState(() {
                                        //         _showDropdown = !_showDropdown;
                                        //       });
                                        //     },
                                        //     icon: Icon(
                                        //       Icons.more_vert,
                                        //       color: widget.theme.disabledColor,
                                        //     ),
                                        //   ),
                                        IconButton(
                                          onPressed: _closeDialog,
                                          icon: Icon(
                                            Icons.close,
                                            color: widget.theme.disabledColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Expanded(child: widget.child),
                                  ],
                                ),
                                // Positioned(
                                //   top: _showDropdown ? 10 : 30,
                                //   right: 30,
                                //   child: AnimatedSlide(
                                //     offset:
                                //         _showDropdown
                                //             ? Offset(0, .5)
                                //             : Offset(0, 0),
                                //     duration: const Duration(milliseconds: 250),
                                //     curve: Curves.easeOut,
                                //     child: AnimatedOpacity(
                                //       opacity: _showDropdown ? 1 : 0,
                                //       duration: const Duration(
                                //         milliseconds: 250,
                                //       ),
                                //       child: Container(
                                //         margin: const EdgeInsets.only(top: 12),
                                //         padding: const EdgeInsets.all(10),
                                //         child: GestureDetector(
                                //           onTap: () => {},
                                //           child: Row(
                                //             mainAxisSize: MainAxisSize.min,
                                //             children: [
                                //               SvgPicture.asset(
                                //                 AppIcons.trashBoldIcon,
                                //                 color: Colors.red,
                                //               ),
                                //               const SizedBox(width: 8),
                                //               Text(
                                //                 "Delete",
                                //                 style: TextStyle(
                                //                   color: Colors.red,
                                //                   fontWeight: FontWeight.w600,
                                //                 ),
                                //               ),
                                //               const SizedBox(width: 8),
                                //             ],
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
