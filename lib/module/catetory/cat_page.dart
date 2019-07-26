import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/app/app.dart';
import 'package:wanandroid/base/base_page.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/common_button.dart';
import 'package:wanandroid/widget/popup_window.dart';

import 'cat_bloc.dart';

class CatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<CatPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  TabController _tabController;
  TabController _subTabController;
  GlobalKey _tabBarKey = GlobalKey();

  @override
  void dispose() {
    _tabController?.dispose();
    _subTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseBlocProvider<CatBloc>(
      blocBuilder: (BuildContext context) {
        return CatBloc();
      },
      child: BlocConsumer<CatBloc>(
        builder: (context, bloc) {
          return ValueListenableBuilder<StateValue>(
            valueListenable: bloc.state,
            builder: (context, state, _) {
              return MultiStateWidget(
                state: state,
                successBuilder: (context) {
                  return Column(
                    children: <Widget>[
                      ValueListenableBuilder<List<ArticleCatEntity>>(
                        valueListenable: bloc.catList,
                        builder: (context, list, _) {
                          _tabController?.dispose();
                          _tabController =
                              TabController(length: list.length, vsync: this);
                          _tabController.addListener(() {
                            bloc.setParentCatPosition(_tabController.index);
                          });
                          return Container(
                            color: MyApp.getTheme(context).primaryColor,
                            child: SafeArea(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TabBar(
                                      key: _tabBarKey,
                                      isScrollable: true,
                                      //是否可以滚动
                                      controller: _tabController,
                                      labelColor: MyApp.getTheme(context)
                                          .tabBarSelectedColor,
                                      unselectedLabelColor:
                                          MyApp.getTheme(context)
                                              .tabBarUnSelectedColor,
                                      labelStyle: TextStyle(fontSize: size(14)),
                                      tabs: () {
                                        return list
                                            .map((e) => Tab(
                                                  text: e.name,
                                                ))
                                            .toList();
                                      }(),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkResponse(
                                      containedInkWell: true,
                                      customBorder: CircleBorder(),
                                      onTap: () {
                                        _showMoreCat(bloc);
                                      },
                                      child: SizedBox(
                                        width: 46,
                                        height: 46,
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          color:
                                              MyApp.getTheme(context).iconColor,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            color: MyApp.getTheme(context).primaryColor,
                            width: double.infinity,
                            child:
                                ValueListenableBuilder<List<ArticleCatEntity>>(
                              valueListenable: bloc.subCatList,
                              builder: (context, list, _) {
                                _subTabController = TabController(
                                    length: list.length, vsync: this);
                                return TabBar(
                                  isScrollable: true,
                                  //是否可以滚动
                                  controller: _subTabController,
                                  labelColor: MyApp.getTheme(context)
                                      .tabBarSelectedColor,
                                  unselectedLabelColor: MyApp.getTheme(context)
                                      .tabBarUnSelectedColor,
                                  labelStyle: TextStyle(fontSize: size(14)),
                                  tabs: () {
                                    return list
                                        .map((e) => Tab(
                                              text: e.name,
                                            ))
                                        .toList();
                                  }(),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Route<dynamic> _moreCatRoute;

  void _closeMoreCat() {
    if (_moreCatRoute?.isCurrent ?? false) {
      Navigator.pop(context);
    }
  }

  void _showMoreCat(CatBloc bloc) {
    BuildContext context = _tabBarKey.currentContext;
    showPopupAsDropdown(
        context: context,
        routeCreatedCallback: (route) => _moreCatRoute = route,
        pageBuilder: (context, animation, __) {
          var animate = Tween<Offset>(begin: Offset(0, -1), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: animation, curve: Curves.linear));
          return GestureDetector(
            onTap: () {
              _closeMoreCat();
            },
            child: Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(color: Colors.black54),
              child: Stack(
                children: <Widget>[
                  ClipRect(
                    child: SlideTransition(
                      position: animate,
                      child: Container(
                        padding: EdgeInsets.all(size(16)),
                        constraints:
                            BoxConstraints.tightFor(width: double.infinity),
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Wrap(
                              runSpacing: size(8),
                              spacing: size(8),
                              children: buildCatFlowChildren(bloc)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.linear),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
        offset: Offset(0, 0));
  }

  List<Widget> buildCatFlowChildren(CatBloc bloc) {
    List<Widget> children = [];
    for (int i = 0; i < bloc.catList.value.length; i++) {
      ArticleCatEntity item = bloc.catList.value[i];
      bool checked = i == _tabController.index;
      var normalTextStyle = TextStyle(
          color: MyApp.getTheme(context).textColorPrimary, fontSize: size(12));

      var checkedTextStyle = TextStyle(
          color: MyApp.getTheme(context).textColorPrimaryInverse,
          fontSize: size(12));

      var checkedWidgetBgColor = MyApp.getTheme(context).checkedWidgetBgColor;

      var unCheckedWidgetBgColor =
          MyApp.getTheme(context).unCheckedWidgetBgColor;

      children.add(CommonButton(
        item.name,
        enable: !checked,
        onPressed: () {
          _closeMoreCat();
          _tabController?.index = i;
        },
        constraints: BoxConstraints.tightFor(height: size(30)),
        textStyle: checked ? checkedTextStyle : normalTextStyle,
        pressedTextStyle: checkedTextStyle,
        bgColor: checked ? checkedWidgetBgColor : unCheckedWidgetBgColor,
        pressedBgColor: checkedWidgetBgColor,
        shapeBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size(15))),
      ));

    }
    return children;
  }
}
