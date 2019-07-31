import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid/base/base_bloc_provider.dart';
import 'package:wanandroid/module/splash/splash_model.dart';

import 'package:wanandroid/app/app.dart';
import 'package:wanandroid/util/auto_size.dart';
import '../../r.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseBlocProvider<SplashBloc>(
      blocBuilder: (context) => SplashBloc(toMain: () {
        Navigator.of(context).pushReplacementNamed(Routes.MAIN);
      }),
      child: Container(
          color: Colors.white,
          child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size(40)),
                child: Image.asset(
                  R.assetsImgLogo,
                  fit: BoxFit.fitHeight,
                ),
              ))),
    );
  }
}
