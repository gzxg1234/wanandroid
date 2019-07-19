import 'dart:ui';

import 'package:wanandroid/base/base_bloc.dart';

class SplashBloc extends BaseBloc {
  final VoidCallback toMain;

  SplashBloc({this.toMain});

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Future.delayed(Duration(seconds: 1), () {
      toMain?.call();
    });
  }
}
