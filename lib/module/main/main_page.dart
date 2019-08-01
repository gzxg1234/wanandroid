import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/app/app_bloc.dart';
import 'package:wanandroid/base/base_view_model_provider.dart';
import 'package:wanandroid/base/view_model_provider.dart';
import 'package:wanandroid/module/catetory/cat_page.dart';
import 'package:wanandroid/module/home/home_page.dart';
import 'package:wanandroid/module/projectcat/project_page.dart';
import 'package:wanandroid/util/auto_size.dart';

import '../../r.dart';
import 'main_vm.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<MainPage> {
  final PageController pageController = PageController(initialPage: 0);
  List<GlobalKey<dynamic>> pageKeys = [
    GlobalKey(debugLabel: "HomePage Key"),
    GlobalKey(debugLabel: "HomePage Key"),
    GlobalKey(debugLabel: "HomePage Key"),
    GlobalKey(debugLabel: "HomePage Key")
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseViewModelProvider<MainVM>(
      viewModelBuilder: (_) {
        return MainVM();
      },
      child: Consumer<MainVM>(builder: (context, bloc, _) {
        return Scaffold(
          backgroundColor: Provider.of<AppBloc>(context).theme.backgroundColor,
          body: PageView.builder(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return HomePage(key: pageKeys[0]);
              } else if (index == 1) {
                return CatPage(key: pageKeys[1]);
              } else if (index == 2) {
                return ProjectPage(key: pageKeys[2]);
              }
              return Container();
            },
          ),
          bottomNavigationBar: ValueListenableBuilder<int>(
              valueListenable: bloc.currentTab,
              builder: (context, value, _) {
                Color selectedColor = Provider.of<AppBloc>(context)
                    .theme
                    .bottomNavigatorSelectedColor;
                Color unSelectedColor = Provider.of<AppBloc>(context)
                    .theme
                    .bottomNavigatorUnSelectedColor;
                return BottomNavigationBar(
                    onTap: (index) {
                      if (index == bloc.currentTab.value) {
                        pageKeys[index].currentState.handleMainTabRepeatTap();
                      }
                      bloc.setCurrentTab(index);
                      pageController.jumpToPage(index);
                    },
                    backgroundColor: Provider.of<AppBloc>(context)
                        .theme
                        .bottomNavigatorBgColor,
                    currentIndex: value,
                    unselectedItemColor: unSelectedColor,
                    type: BottomNavigationBarType.fixed,
                    selectedIconTheme: IconThemeData(color: selectedColor),
                    unselectedIconTheme: IconThemeData(color: unSelectedColor),
                    selectedItemColor: selectedColor,
                    iconSize: size(24),
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
                        activeIcon: ImageIcon(AssetImage(R.assetsImgTabGzh)),
                        icon: ImageIcon(AssetImage(R.assetsImgTabGzh)),
                      ),
                    ]);
              }),
        );
      }),
    );
    ;
  }
}
