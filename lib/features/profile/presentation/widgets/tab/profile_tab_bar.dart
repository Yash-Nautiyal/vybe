import 'package:flutter/material.dart';
import 'package:vybe/core/constants/app_icons.dart';
import 'package:vybe/core/widgets/icon/app_svg_icon.dart';

class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({super.key});

  static const _tabIcons = [
    AppIcons.profileGridIcon,
    AppIcons.profileCommentIcon,
    AppIcons.profileStarIcon,
    AppIcons.profileFriendsIcon,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    final tabTheme = Theme.of(context).tabBarTheme;

    return TabBar(
      tabs: [
        for (var i = 0; i < _tabIcons.length; i++)
          Tab(
            height: 48,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final selected = controller.index == i;
                return AppSvgIcon(
                  asset: _tabIcons[i],
                  size: 24,
                  color:
                      selected
                          ? tabTheme.labelColor
                          : tabTheme.unselectedLabelColor,
                );
              },
            ),
          ),
      ],
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.tab,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
    );
  }
}
