import 'dart:ui';

import 'package:flutter/material.dart';

class AppTheme {
  Color get primaryColor => Color(0xff2196f3);

  Color get canvasColor => Colors.white;

  Color get accentColor =>primaryColor;

  Color get appBarBgColor => primaryColor;

  Color get appBarTextIconColor => Colors.white;

  Color get activeIconColor => primaryColor;

  Color get backgroundColor => Colors.white;

  Color get listBackgroundColor => Color(0xfff5f5f5);

  Color get bottomNavigatorBgColor => Colors.white;

  Color get bottomNavigatorUnSelectedColor => Colors.black54;

  Color get bottomNavigatorSelectedColor => primaryColor;

  Color get tabBarSelectedColor => Colors.white;

  Color get tabBarUnSelectedColor => Colors.white70;

  Color get textColorPrimaryInverse => Colors.white;

  Color get textColorPrimary => Color(0xff212121);

  Color get textColorSecondary => Color(0xff666666);

  Color get textColor3 => Color(0xff999999);

  Color get cardColor => Colors.white;

  Color get pageIndicatorActiveColor => primaryColor;

  Color get pageIndicatorNormalColor => Colors.grey[200];

  Color get flagTextColor => Colors.red;

  Color get searchHighLight => Colors.red;

  Color get tagBgColor => Colors.grey[200];

  Color get tagBgColorChecked => primaryColor;

  Color get popMenuBgColor => Colors.white;
}

class DarkTheme extends AppTheme {
  @override
  Color get primaryColor => Colors.grey[900];

  @override
  Color get accentColor =>Colors.white;

  @override
  Color get canvasColor => Colors.grey[900];

  @override
  Color get appBarTextIconColor => Colors.white70;

  Color get appBarBgColor => primaryColor;

  Color get activeIconColor => Colors.white70;

  Color get backgroundColor => Colors.black;

  Color get listBackgroundColor => Colors.black;

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

  @override
  Color get tagBgColor => Colors.grey[900];

  @override
  Color get tagBgColorChecked => Colors.grey[500];

  @override
  Color get popMenuBgColor => Colors.grey[800];
}
