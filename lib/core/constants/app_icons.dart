class AppIcons {
  AppIcons._();

  // --------------- ICON PATHS ---------------

  // static const String _basePath = 'assets/icons';
  static const String _arrowPath = 'assets/icons/arrow';
  static const String _solidPath = 'assets/icons/solid';
  static const String _illustrationsPath = 'assets/illustrations';
  static const String _navPath = 'assets/icons/nav';
  static const String _emptyPath = 'assets/icons/empty';

  // --------------- ILLUSTRATIONS ---------------
  static const String confirmIllustration =
      '$_illustrationsPath/ic-email-inbox.svg';
  static const String forgotPasswordIllustration =
      '$_illustrationsPath/ic-password.svg';
  static const String offlineIllustration =
      '$_illustrationsPath/ic-no-wifi.svg';

  // --------------- ARROW ICONS ---------------
  static const String checkRoundedIcon = '$_arrowPath/ic-solid-check-one.svg';
  static const String redirectIcon = '$_arrowPath/ic-redirect.svg';
  static const String restartBoldIcon = '$_arrowPath/ic-solar_restart-bold';
  static const String chatLinearIcon =
      '$_arrowPath/ic-solar-chat-line-linear.svg';
  static const String heartLinearIcon = '$_arrowPath/ic-solar-heart-linear.svg';
  static const String shareLinearIcon = '$_arrowPath/ic-solar-share-linear.svg';
  static const String starLinearIcon = '$_arrowPath/ic-solar-star-linear.svg';

  // --------------- SOLID ICONS ---------------
  static const String calenderDuoIcon =
      '$_solidPath/ic-solar-calendar-mark-bold-duotone.svg';
  static const String listBoldIcon = '$_solidPath/ic-solar-list.svg';
  static const String widgetBoldIcon = '$_solidPath/ic-solar-widget.svg';
  static const String penBoldIcon = '$_solidPath/ic-solar_pen-bold.svg';
  static const String trashBoldIcon = '$_solidPath/ic-solar_trash-bold.svg';

  // --------------- NAV ICONS ---------------
  static const String homeIcon = '$_navPath/ic-home.svg';
  static const String listBoldDuotoneIcon =
      '$_navPath/ic-list-bold-duotone.svg';
  static const String userManagementIcon =
      '$_navPath/ic-user-management.svg';

  // --------------- PROFILE ICONS ---------------
  static const String profileGridIcon = widgetBoldIcon;
  static const String profileCommentIcon = chatLinearIcon;
  static const String profileStarIcon = starLinearIcon;
  static const String profileFriendsIcon = userManagementIcon;
  static const String profileBellIcon = alertIcon;
  static const String profileSettingsIcon = settingIcon;
  static const String profileEditIcon = penBoldIcon;

  // --------------- COMMON ICONS ---------------
  static const String searchFillIcon = '$_solidPath/ic-eva_search-fill.svg';
  static const String calendarIcon = '$_solidPath/ic-calender.svg';
  static const String settingIcon = '$_solidPath/ic-settings.svg';
  static const String alertIcon = '$_solidPath/ic-alert.svg';
  static const String heartBoldIcon = '$_solidPath/ic-solar-heart-bold.svg';
  static const String starBoldIcon = '$_solidPath/ic-solar-star-bold.svg';

  // --------------- EMPTY ICONS ---------------
  static const String emptyCartIcon = '$_emptyPath/ic-cart.svg';
  static const String emptyEmailIcon = '$_emptyPath/ic-email-disabled.svg';
  static const String emptyChatIcon = '$_emptyPath/ic-chat-active.svg';
  static const String emptyContentIcon = '$_emptyPath/ic-content.svg';
  static const String emptyFolderIcon = '$_emptyPath/ic-folder-empty.svg';
}
