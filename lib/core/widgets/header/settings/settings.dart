import 'package:flutter/material.dart';
import '../../dialog/slide_dialog.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideDialog(
      theme: theme,
      title: 'Settings',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [SizedBox.shrink()],
        ),
      ),
    );
  }
}
