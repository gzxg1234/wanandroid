import 'package:flutter/material.dart';
import 'package:wanandroid/base/base_page.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/module/catetory/cat_page.dart';
import 'package:wanandroid/module/home/home_page.dart';
import 'package:wanandroid/util/size_adapter.dart';
import 'package:wanandroid/widget/save_state_indexed_stack.dart';

import '../../r.dart';
import 'main_bloc.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseBlocProvider<MainBloc>(
      blocBuilder: (_) => MainBloc(),
      child: BlocConsumer<MainBloc>(builder: (context, bloc) {
        return Scaffold(
          body: ValueListenableBuilder(
            valueListenable: bloc.currentTab,
            builder: (_, v, __) {
              return SaveStateIndexedStack(
                widgets: <Widget>[HomePage(), CatPage()],
                index: v,
              );
            },
          ),
          bottomNavigationBar: ValueListenableBuilder<int>(
              valueListenable: bloc.currentTab,
              builder: (context, value, _) {
                Color primaryColor = Theme.of(context).primaryColor;
                return BottomNavigationBar(
                    onTap: (index) {
                      bloc.setCurrentTab(index);
                    },
                    currentIndex: value,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: primaryColor,
                    iconSize: $size(24),
                    items: [
                      BottomNavigationBarItem(
                        title: Text("首页"),
                        activeIcon: ImageIcon(AssetImage(R.assetsImgTabHome),
                            color: primaryColor),
                        icon: ImageIcon(AssetImage(R.assetsImgTabHome),
                            color: Colors.grey),
                      ),
                      BottomNavigationBarItem(
                        title: Text("体系"),
                        activeIcon: ImageIcon(AssetImage(R.assetsImgTabTixi),
                            color: primaryColor),
                        icon: ImageIcon(AssetImage(R.assetsImgTabTixi),
                            color: Colors.grey),
                      ),
                      BottomNavigationBarItem(
                        title: Text("项目"),
                        activeIcon: ImageIcon(AssetImage(R.assetsImgTabXm),
                            color: primaryColor),
                        icon: ImageIcon(AssetImage(R.assetsImgTabXm),
                            color: Colors.grey),
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
  }
}
