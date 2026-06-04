import 'package:flutter/material.dart';
import 'package:vybe/core/constants/app_icons.dart';
import 'package:vybe/core/widgets/empty/empty_content.dart';

class MentionsBody extends StatelessWidget {
  const MentionsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyContent(
      icon: AppIcons.emptyContentIcon,
      title: 'No friends yet',
    );
  }
}
