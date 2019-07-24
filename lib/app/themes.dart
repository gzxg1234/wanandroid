import 'dart:ui';

import 'package:flutter/material.dart';

class AppTheme {
  Color get itemTitleColor => Color(0xff333333);

  Color get primaryColor => Color(0xff2196f3);

  Color get backgroundColor => Colors.white;

  Color get bottomNavigatorBgColor => Colors.white;

  Color get bottomNavigatorUnSelectedColor => Colors.black54;

  Color get bottomNavigatorSelectedColor => Colors.blue;

  Color get textColorPrimaryInverse => Colors.white;

  Color get textColorPrimary => Color(0xff212121);

  Color get textColorSecondary => Color(0xff757575);

  Color get cardColor => Colors.white;
}

class DarkTheme extends AppTheme {
  @override
  Color get itemTitleColor => Colors.white;

  @override
  Color get primaryColor => Colors.grey[900];

  Color get backgroundColor => Colors.black;

  @override
  Color get bottomNavigatorSelectedColor => Colors.white;

  @override
  Color get bottomNavigatorBgColor => primaryColor;

  @override
  Color get bottomNavigatorUnSelectedColor => Colors.white60;

  @override
  Color get textColorPrimary => Colors.white;

  @override
  Color get textColorSecondary => Colors.white;

  Color get cardColor => primaryColor;
}
