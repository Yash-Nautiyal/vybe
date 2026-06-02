class AppIcons {
  AppIcons._(); // Private constructor prevents instantiation

  static const String _basePath = 'assets/icons';
  static const String _arrowPath = 'assets/icons/arrow';
  static const String _solidPath = 'assets/icons/solid';
  static const String _illustrationsPath = 'assets/illustrations';
  static const String _navPath = 'assets/icons/nav';

  // illustrations
  static const String confirmIllustration =
      '$_illustrationsPath/ic-email-inbox.svg';
  static const String forgotPasswordIllustration =
      '$_illustrationsPath/ic-password.svg';

  //arrow icons
  static const String checkRoundedIcon = '$_arrowPath/ic-solid-check-one.svg';
  static const String redirectIcon = '$_arrowPath/ic-redirect.svg';

  //solid icons
  static const String calenderDuoIcon =
      '$_solidPath/ic-solar-calendar-mark-bold-duotone.svg';
  static const String listBoldIcon = '$_solidPath/ic-solar-list.svg';
  static const String widgetBoldIcon = '$_solidPath/ic-solar-widget.svg';
  static const String penBoldIcon = '$_solidPath/ic-solar_pen-bold.svg';
  static const String trashBoldIcon = '$_solidPath/ic-solar_trash-bold.svg';

  //nav icons
  static const String homeIcon = '$_navPath/ic-home.svg';
  static const String listBoldDuotoneIcon =
      '$_navPath/ic-list-bold-duotone.svg';

  //Common Icons
  static const String searchFillIcon = '$_basePath/ic-eva_search-fill.svg';
  static const String calendarIcon = '$_basePath/ic-calender.svg';
  static const String settingIcon = '$_basePath/ic-settings.svg';
  static const String sunIcon = '$_basePath/ic-sun.svg';
  static const String moonIcon = '$_basePath/ic-moon.svg';
}
