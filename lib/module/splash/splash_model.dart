import 'dart:ui';

import 'package:wanandroid/base/base_view_model.dart';

class SplashVM extends BaseViewModel {
  final VoidCallback toMain;

  SplashVM({this.toMain});

  @override
  void initial() {
    // TODO: implement onInit
    super.initial();
    Future.delayed(Duration(seconds: 1), () {
      toMain?.call();
    });
  }
}
