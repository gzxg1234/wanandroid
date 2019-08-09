import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/base/base_state.dart';
import 'package:wanandroid/base/base_view_model_provider.dart';
import 'package:wanandroid/component/common_list.dart';
import 'package:wanandroid/component/item_article.dart';
import 'package:wanandroid/component/more_tab_window.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/component/tab_pager.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/event/events.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/util/widget_utils.dart';
import 'package:wanandroid/widget/keep_alive.dart';
import 'package:wanandroid/widget/refresh_indicator_fix.dart';
import 'package:wanandroid/widget/rotation_view.dart';

import '../../main.dart';
import 'cat_bloc.dart';

class CatPage extends StatefulWidget {
  CatPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CatPageState();
  }
}

class CatPageState extends State<CatPage>
    with
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin,
        BaseStateMixin {
  @override
  bool get wantKeepAlive => true;

  CatBloc _bloc;

  TabController _tabController;

  MoreTabWindow _moreTabWindow;

  GlobalKey _tabBarKey = GlobalKey();

  GlobalKey<RefreshIndicatorFixState> _refreshIndicatorKey = GlobalKey();

  GlobalKey<RotationViewState> _dropDownButtonKey = GlobalKey();

  GlobalObjectKey<TabPagerState> _tabPagerKey;

  List<GlobalKey<CommonListState>> pageKeys;

  List<ScrollController> pageScrollControllers;

  @override
  void initState() {
    super.initState();
    _bloc = CatBloc();
    onEvent<MainTabReTapEvent>((e) {
      if (e.index == 1) {
        handleMainTabRepeatTap();
      }
    });
    _bloc.childTabList.addListener(() {
      _tabPagerKey = GlobalObjectKey(_bloc.childTabList.value);
      pageKeys = List.generate(_bloc.childTabList.value.length,
          (i) => GlobalObjectKey(_bloc.childTabList.value[i]));
      pageScrollControllers = List.generate(
          _bloc.childTabList.value.length, (i) => ScrollController());
    });

    _bloc.childTabIndex.addListener(() {
      try {
        _tabPagerKey?.currentState?.jumpTo(_bloc.childTabIndex.value);
      } catch (e) {}
    });

    _bloc.parentTabList.addListener(() {
      _tabController?.dispose();
      _tabController = TabController(
          length: _bloc.parentTabList.value.length,
          vsync: this,
          initialIndex: _bloc.parentTabIndex.value);
      _tabController.addListener(() {
        _bloc.parentIndexChange(_tabController.index);
      });
    });

    _bloc.parentTabIndex.addListener(() {
      _tabController.index = _bloc.parentTabIndex.value;
    });
  }

  @override
  void dispose() {
    _moreTabWindow?.dismiss();
    _tabController?.dispose();
    super.dispose();
  }

  void handleMainTabRepeatTap() {
    if (_bloc.state.value == StateValue.Success) {
      EventBus.post(MainTabShowRefreshEvent(1, true));
      _refreshIndicatorKey.currentState.show().whenComplete(() {
        EventBus.post(MainTabShowRefreshEvent(1, false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseBlocProvider<CatBloc>(
      viewModelBuilder: (BuildContext context) {
        return _bloc;
      },
      child: Consumer<CatBloc>(
        builder: (context, bloc, _) {
          return ValueListenableBuilder<StateValue>(
            valueListenable: bloc.state,
            builder: (context, state, _) {
              return MultiStateWidget(
                state: state,
                onPressedRetry: bloc.fetchCategoryData,
                successBuilder: (context) {
                  return RefreshIndicatorFix(
                    key: _refreshIndicatorKey,
                    onRefresh: () => bloc.fetchCategoryData(false),
                    child: Column(
                      children: <Widget>[
                        ValueListenableBuilder<List<CategoryEntity>>(
                          valueListenable: bloc.parentTabList,
                          builder: (context, list, _) {
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
                                        indicatorColor: MyApp.getTheme(context)
                                            .tabBarSelectedColor,
                                        labelColor: MyApp.getTheme(context)
                                            .tabBarSelectedColor,
                                        unselectedLabelColor:
                                            MyApp.getTheme(context)
                                                .tabBarUnSelectedColor,
                                        labelStyle:
                                            TextStyle(fontSize: sizeW(14)),
                                        tabs: () {
                                          return list
                                              .map((e) => Tab(
                                                    text: e.name,
                                                  ))
                                              .toList();
                                        }(),
                                      ),
                                    ),
                                    Semantics(
                                      button: true,
                                      label: "显示全部分类",
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkResponse(
                                          containedInkWell: true,
                                          customBorder: CircleBorder(),
                                          onTap: () {
                                            _dropDownButtonKey.currentState
                                                ?.forward();
                                            _showMoreCat(list);
                                          },
                                          child: SizedBox(
                                            width: 46,
                                            height: 46,
                                            child: RotationView(
                                              key: _dropDownButtonKey,
                                              fromDegree: 0,
                                              toDegree: -180,
                                              duration:
                                                  Duration(milliseconds: 300),
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                                color: MyApp.getTheme(context)
                                                    .appBarTextIconColor,
                                              ),
                                            ),
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
                        Expanded(
                          child: ValueListenableBuilder<List<CategoryEntity>>(
                            valueListenable: bloc.childTabList,
                            child: Offstage(),
                            builder: (context, tabList, empty) {
                              if (tabList == null) {
                                return empty;
                              }
                              return TabPager(
                                initialIndex: bloc.childTabIndex.value,
                                key: _tabPagerKey,
                                tabs: tabList.map((e) => e.name).toList(),
                                onTabReTap: (index) {
                                  if (pageScrollControllers[index].offset ==
                                      0) {
                                    pageKeys[index].currentState?.refresh();
                                  } else {
                                    scrollToTop(pageScrollControllers[index]);
                                  }
                                },
                                pageBuilder: (_, index) {
                                  final int id = tabList[index].id;
                                  return KeepAliveContainer(
                                    child: CommonList<ArticleEntity>(
                                      key: pageKeys[index],
                                      padding: EdgeInsets.all(sizeW(12)),
                                      scrollController:
                                          pageScrollControllers[index],
                                      startPage: 0,
                                      dataProvider: (page) {
                                        return bloc.fetchList(page, id);
                                      },
                                      separatorBuilder: (_, index) {
                                        return SizedBox(height: sizeW(8));
                                      },
                                      itemBuilder: (BuildContext context, item,
                                          int index) {
                                        return ArticleItem(item);
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showMoreCat(List<CategoryEntity> catList) {
    _moreTabWindow = MoreTabWindow(
        catList.map((e) => e.name).toList(), _tabController.index);
    _moreTabWindow
        .showAsDropdown(targetContext: _tabBarKey.currentContext)
        .then((index) {
      _dropDownButtonKey.currentState?.reverse();
      if (index != null) {
        _tabController?.index = index;
      }
    });
  }
}
