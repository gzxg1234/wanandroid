import 'package:flutter/material.dart';
import 'package:wanandroid/util/size_adapter.dart';

import 'module/main/main_page.dart';
import 'module/splash/splash_page.dart';

void main() => runApp(MyApp());

class RouteNames {
  static const MAIN = "/main";
  static const SPLASH = "/";
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '玩Android',
      builder: (context, widget) {
        $designWidth(375, MediaQuery.of(context).orientation);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: widget,
        );
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      routes: {
        RouteNames.SPLASH: (context) => SplashPage(),
        RouteNames.MAIN: (context) => MainPage(),
      },
    );
  }
}
