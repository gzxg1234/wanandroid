import 'package:flutter/cupertino.dart';

int _designWidth;
Orientation currentOrientation;

void $designWidth(int designWidth, Orientation orientation) {
  _designWidth = designWidth;
  currentOrientation = orientation;
}

double $size(int px) {
  var window = WidgetsBinding.instance.window;
  double width = window.physicalSize.width;
  if (currentOrientation == Orientation.landscape) {
    width = window.physicalSize.height;
  }
  double widthDp = width / window.devicePixelRatio;
  double result = px / _designWidth * widthDp;
  return result;
}
