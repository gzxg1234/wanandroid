import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/app/app_bloc.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/base/base_state.dart';
import 'package:wanandroid/base/base_view_model_provider.dart';
import 'package:wanandroid/base/builders.dart';
import 'package:wanandroid/event/events.dart';
import 'package:wanandroid/module/catetory/cat_page.dart';
import 'package:wanandroid/module/home/home_page.dart';
import 'package:wanandroid/module/projectcat/project_page.dart';
import 'package:wanandroid/module/woa/wx_page.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/progress_view.dart';

import '../../r.dart';
import 'main_bloc.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<MainPage> with BaseStateMixin {
  final PageController pageController = PageController(initialPage: 0);

  MainBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = MainBloc();
    onEvent<SwitchHomeTabEvent>((e){
      _bloc.setCurrentTab(e.index);
      pageController.jumpToPage(e.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseBlocProvider<MainBloc>(
      viewModelBuilder: (_) {
        return _bloc;
      },
      child: Consumer<MainBloc>(builder: (context, bloc, _) {
        return Scaffold(
          backgroundColor: Provider.of<AppBloc>(context).theme.backgroundColor,
          body: PageView.builder(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return HomePage();
              } else if (index == 1) {
                return CatPage();
              } else if (index == 2) {
                return ProjectPage();
              }
              return WxPage();
            },
          ),
          bottomNavigationBar: MultiValueListenableBuilder(
              valueListenableList: [bloc.currentTab, bloc.tabRefreshing],
              builder: (context, values, _) {
                Color selectedColor = Provider.of<AppBloc>(context)
                    .theme
                    .bottomNavigatorSelectedColor;
                Color unSelectedColor = Provider.of<AppBloc>(context)
                    .theme
                    .bottomNavigatorUnSelectedColor;
                return BottomNavigationBar(
                    onTap: (index) {
                      if (index == values[0]) {
                        EventBus.post(MainTabReTapEvent(index));
                      }
                      bloc.setCurrentTab(index);
                      pageController.jumpToPage(index);
                    },
                    backgroundColor: Provider.of<AppBloc>(context)
                        .theme
                        .bottomNavigatorBgColor,
                    currentIndex: values[0],
                    unselectedItemColor: unSelectedColor,
                    type: BottomNavigationBarType.fixed,
                    selectedIconTheme: IconThemeData(color: selectedColor),
                    unselectedIconTheme: IconThemeData(color: unSelectedColor),
                    selectedItemColor: selectedColor,
                    iconSize: sizeW(24),
                    items: buildTab(values[1]));
              }),
        );
      }),
    );
  }

  List<BottomNavigationBarItem> buildTab(List<bool> refreshing) {
    return [
      BottomNavigationBarItem(
        title: Text("首页"),
        icon: refreshing[0]
            ? ProgressView(child: Icon(Icons.refresh))
            : ImageIcon(AssetImage(R.assetsImgTabHome)),
      ),
      BottomNavigationBarItem(
        title: Text("体系"),
        icon: refreshing[1]
            ? ProgressView(child: Icon(Icons.refresh))
            : ImageIcon(AssetImage(R.assetsImgTabTixi)),
      ),
      BottomNavigationBarItem(
        title: Text("项目"),
        icon: refreshing[2]
            ? ProgressView(child: Icon(Icons.refresh))
            : ImageIcon(AssetImage(R.assetsImgTabXm)),
      ),
      BottomNavigationBarItem(
        title: Text("公众号"),
        icon: refreshing[3]
            ? ProgressView(child: Icon(Icons.refresh))
            : ImageIcon(AssetImage(R.assetsImgTabGzh)),
      ),
    ];
  }
}
