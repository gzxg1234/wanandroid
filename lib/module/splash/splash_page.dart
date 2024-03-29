import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid/base/base_view_model_provider.dart';
import 'package:wanandroid/main.dart';
import 'package:wanandroid/module/splash/splash_bloc.dart';
import 'package:wanandroid/util/auto_size.dart';

import '../../r.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseBlocProvider<SplashBloc>(
      viewModelBuilder: (context) => SplashBloc(toMain: () {
        Navigator.of(context).pushReplacementNamed(Routes.MAIN);
      }),
      child: Container(
          color: Colors.white,
          child: Center(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sizeW(40)),
            child: Image.asset(
              R.assetsImgLogo,
              fit: BoxFit.fitHeight,
            ),
          ))),
    );
  }
}
