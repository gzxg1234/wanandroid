import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid/base/base_page.dart';
import 'package:wanandroid/module/splash/splash_model.dart';
import 'package:wanandroid/util/size_adapter.dart';

import '../../app.dart';
import '../../r.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseBlocProvider<SplashBloc>(
      blocBuilder: (context) => SplashBloc(toMain: () {
        Navigator.of(context).pushReplacementNamed(RouteNames.MAIN);
      }),
      child: Container(
          color: Colors.white,
          child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: $size(40)),
                child: Image.asset(
                  R.assetsImgLogo,
                  fit: BoxFit.fitHeight,
                ),
              ))),
    );
  }
}
