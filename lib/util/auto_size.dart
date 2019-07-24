import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

int _designWidth;

void runAutoSizeApp(int designWidth, Widget app) {
  _designWidth = designWidth;
  AutoSizeWidgetsFlutterBinding.ensureInitialized()
    ..attachRootWidget(app)
    ..scheduleWarmUpFrame();
}

class AutoSizeWidgetsFlutterBinding extends WidgetsFlutterBinding {
  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) AutoSizeWidgetsFlutterBinding();
    return WidgetsBinding.instance;
  }

  @override
  ViewConfiguration createViewConfiguration() {
    double devicePixelRatio = window.devicePixelRatio;
    devicePixelRatio = window.physicalSize.width / _designWidth;
    return ViewConfiguration(
      size: window.physicalSize / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
    );
  }
}
