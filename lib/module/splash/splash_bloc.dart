import 'dart:ui';

import 'package:wanandroid/base/base_bloc.dart';


class SplashBloc extends BaseBloc {
  final VoidCallback toMain;

  SplashBloc({this.toMain});

  @override
  void initial() {
    super.initial();
    Future.delayed(Duration(seconds: 1), () {
      toMain?.call();
    });
  }
}
