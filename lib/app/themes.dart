import 'dart:ui';

import 'package:flutter/material.dart';

class AppTheme {
  Color get iconColor => Colors.white;

  Color get primaryColor => Color(0xff2196f3);

  Color get backgroundColor => Colors.white;

  Color get bottomNavigatorBgColor => Colors.white;

  Color get bottomNavigatorUnSelectedColor => Colors.black54;

  Color get bottomNavigatorSelectedColor => primaryColor;

  Color get tabBarSelectedColor => Colors.white;

  Color get tabBarUnSelectedColor => Colors.white70;

  Color get textColorPrimaryInverse => Colors.white;

  Color get textColorPrimary => Color(0xff212121);

  Color get textColorSecondary => Color(0xff666666);

  Color get cardColor => Colors.white;

  Color get pageIndicatorActiveColor => primaryColor;

  Color get pageIndicatorNormalColor => Colors.grey[200];

  Color get flagTextColor => Colors.red;

  Color get unCheckedWidgetBgColor => Colors.grey[200];
  Color get checkedWidgetBgColor => primaryColor;
}

class DarkTheme extends AppTheme {
  @override
  Color get iconColor => Colors.white70;

  @override
  Color get primaryColor => Colors.grey[900];

  Color get backgroundColor => Colors.black;

  @override
  Color get bottomNavigatorBgColor => primaryColor;

  @override
  Color get bottomNavigatorSelectedColor => Colors.white54;

  @override
  Color get bottomNavigatorUnSelectedColor => Colors.white30;

  @override
  Color get textColorPrimary => Colors.white54;

  @override
  Color get textColorSecondary => Colors.white30;

  @override
  Color get textColorPrimaryInverse => Colors.white54;

  @override
  Color get cardColor => primaryColor;

  @override
  Color get pageIndicatorActiveColor => Colors.white70;

  @override
  Color get pageIndicatorNormalColor => Colors.white30;
}
