import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid/app/app_bloc.dart';
import 'package:wanandroid/base/base_page.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/module/catetory/cat_page.dart';
import 'package:wanandroid/module/home/home_page.dart';

import '../../r.dart';
import 'main_bloc.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<MainPage> {
  final PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseBlocProvider<MainBloc>(
      blocBuilder: (_) {
        return MainBloc();
      },
      child: BlocConsumer<MainBloc>(builder: (context, bloc) {
        return Scaffold(
          backgroundColor:
              BlocProvider.of<AppBloc>(context).theme.backgroundColor,
          body: PageView.builder(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return HomePage();
              } else {
                return CatPage();
              }
            },
          ),
          bottomNavigationBar: ValueListenableBuilder<int>(
              valueListenable: bloc.currentTab,
              builder: (context, value, _) {
                Color primaryColor = Theme.of(context).primaryColor;
                Color selectedColor = BlocProvider.of<AppBloc>(context)
                    .theme
                    .bottomNavigatorSelectedColor;
                Color unSelectedColor = BlocProvider.of<AppBloc>(context)
                    .theme
                    .bottomNavigatorUnSelectedColor;
                return BottomNavigationBar(
                    onTap: (index) {
                      bloc.setCurrentTab(index);
                      pageController.jumpToPage(index);
                    },
                    backgroundColor: BlocProvider.of<AppBloc>(context)
                        .theme
                        .bottomNavigatorBgColor,
                    currentIndex: value,
                    unselectedItemColor: unSelectedColor,
                    type: BottomNavigationBarType.fixed,
                    selectedIconTheme: IconThemeData(color: selectedColor),
                    unselectedIconTheme: IconThemeData(color: unSelectedColor),
                    selectedItemColor: selectedColor,
                    iconSize:24,
                    items: [
                      BottomNavigationBarItem(
                        title: Text("首页"),
                        activeIcon: ImageIcon(AssetImage(R.assetsImgTabHome)),
                        icon: ImageIcon(AssetImage(R.assetsImgTabHome)),
                      ),
                      BottomNavigationBarItem(
                        title: Text("体系"),
                        activeIcon: ImageIcon(AssetImage(R.assetsImgTabTixi)),
                        icon: ImageIcon(AssetImage(R.assetsImgTabTixi)),
                      ),
                      BottomNavigationBarItem(
                        title: Text("项目"),
                        activeIcon: ImageIcon(AssetImage(R.assetsImgTabXm)),
                        icon: ImageIcon(AssetImage(R.assetsImgTabXm)),
                      ),
                      BottomNavigationBarItem(
                        title: Text("公众号"),
                        activeIcon: ImageIcon(AssetImage(R.assetsImgTabGzh),
                            color: primaryColor),
                        icon: ImageIcon(AssetImage(R.assetsImgTabGzh),
                            color: Colors.grey),
                      ),
                    ]);
              }),
        );
      }),
    );
    ;
  }
}
