import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/app/themes.dart';
import 'package:wanandroid/module/main/main_page.dart';
import 'package:wanandroid/module/splash/splash_page.dart';
import 'package:wanandroid/module/web/web_page.dart';
import 'package:wanandroid/util/auto_size.dart';

import 'app/app_bloc.dart';
import 'app/hot_word_bloc.dart';
import 'base/base_view_model_provider.dart';
import 'module/search/search_page.dart';

void main() => runApp(MyApp());

class Routes {
  static const SPLASH = "/";

  static const MAIN = "/main";

  static const WEB = "/web";
  static const WEB_ARG_URL = "url";

  static const SEARCH = "/search";
}

class MyApp extends StatelessWidget {
  static AppTheme getTheme(BuildContext context) {
    return Provider.of<AppBloc>(context).theme;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    autoSize(375, 667);
    return BaseViewModelProvider<AppBloc>(
      viewModelBuilder: (_) => AppBloc(),
      child: BaseViewModelProvider<HotWordVM>(
        viewModelBuilder: (_) => HotWordVM(),
        child: Consumer<AppBloc>(
          builder: (_, bloc, __) {
            return MaterialApp(
              title: '玩Android',
              builder: (context, widget) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: widget,
                );
              },
              onGenerateRoute: (settings) {
                Widget page;
                switch (settings.name) {
                  case Routes.SPLASH:
                    page = SplashPage();
                    break;
                  case Routes.MAIN:
                    page = MainPage();
                    break;
                  case Routes.WEB:
                    page = WebPage(
                        (settings.arguments as Map)[Routes.WEB_ARG_URL]);
                    break;
                  case Routes.SEARCH:
                    page = SearchPage();
                    break;
                }
                return MaterialPageRoute(
                    builder: (context) => page, settings: settings);
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
                  primaryColor: bloc.theme.primaryColor),
//            routes: {
//              RouteNames.SPLASH: (context) => SplashPage(),
//              RouteNames.MAIN: (context) => MainPage(),
//            },
            );
          },
        ),
      ),
    );
  }
}
