import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/base/base_state.dart';
import 'package:wanandroid/base/base_view_model_provider.dart';
import 'package:wanandroid/component/more_tab_window.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/event/events.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/refresh_indicator_fix.dart';
import 'package:wanandroid/widget/rotation_view.dart';

import '../../main.dart';
import 'article_list.dart';
import 'cat_vm.dart';

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

  CatVM _catBloc;

  bool _tabChangeFromPage = false;

  TabController _tabController;

  TabController _subTabController;

  PageController _pageController;

  MoreTabWindow _moreTabWindow;

  GlobalKey _tabBarKey = GlobalKey();

  GlobalKey<RefreshIndicatorFixState> _refreshIndicatorKey = GlobalKey();

  GlobalKey<RotationViewState> _dropDownButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    onEvent<MainTabReTapEvent>((e) {
      if (e.index == 1) {
        handleMainTabRepeatTap();
      }
    });
  }

  @override
  void dispose() {
    _moreTabWindow?.dismiss();
    _tabController?.dispose();
    _subTabController?.dispose();
    super.dispose();
  }

  void handleMainTabRepeatTap() {
    if (_catBloc.state.value == StateValue.Success) {
      EventBus.send(MainTabShowRefreshEvent(1, true));
      _refreshIndicatorKey.currentState.show().whenComplete(() {
        EventBus.send(MainTabShowRefreshEvent(1, false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseViewModelProvider<CatVM>(
      viewModelBuilder: (BuildContext context) {
        return _catBloc = CatVM();
      },
      child: Consumer<CatVM>(
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
                        ValueListenableBuilder<CatTabState>(
                          valueListenable: bloc.parentTabState,
                          builder: (context, tabState, _) {
                            _tabController?.dispose();
                            _tabController = TabController(
                                length: tabState.list.length,
                                vsync: this,
                                initialIndex: tabState.index);
                            _tabController.addListener(() {
                              bloc.parentIndexChange(_tabController.index);
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
                                        labelStyle:
                                            TextStyle(fontSize: sizeW(14)),
                                        tabs: () {
                                          return tabState.list
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
                                            _showMoreCat(tabState.list);
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
                                                    .iconColor,
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
                          child: ValueListenableBuilder<CatTabState>(
                            valueListenable: bloc.childTabState,
                            builder: (context, tabState, _) {
                              _subTabController = TabController(
                                  length: tabState.list.length,
                                  vsync: this,
                                  initialIndex: tabState.index);
                              _subTabController.addListener(() {
                                bloc.childIndexChange(_subTabController.index);
                                if (!_tabChangeFromPage) {
                                  _pageController
                                      .jumpToPage(_subTabController.index);
                                } else {
                                  _tabChangeFromPage = false;
                                }
                              });

                              _pageController = PageController(
                                  initialPage: tabState.index, keepPage: false);
                              List<GlobalKey<dynamic>> pageKeys =
                                  List.generate(tabState.list.length, (i) {
                                return GlobalKey();
                              });

                              return Column(
                                children: <Widget>[
                                  Container(
                                      color:
                                          MyApp.getTheme(context).primaryColor,
                                      width: double.infinity,
                                      child: TabBar(
                                          key: ObjectKey(tabState.list),
                                          isScrollable: true,
                                          onTap: (index) {
                                            if (!_subTabController
                                                .indexIsChanging) {
                                              pageKeys[index]
                                                  .currentState
                                                  ?.onParentTabTap();
                                            }
                                          },
                                          //是否可以滚动
                                          controller: _subTabController,
                                          labelColor: MyApp.getTheme(context)
                                              .tabBarSelectedColor,
                                          unselectedLabelColor:
                                              MyApp.getTheme(context)
                                                  .tabBarUnSelectedColor,
                                          unselectedLabelStyle:
                                              TextStyle(fontSize: sizeW(14)),
                                          labelStyle:
                                              TextStyle(fontSize: sizeW(14)),
                                          tabs: () {
                                            return tabState.list
                                                .map((e) => Tab(
                                                      text: e.name,
                                                    ))
                                                .toList();
                                          }())),
                                  Expanded(
                                    child: PageView.builder(
                                        key: ObjectKey(tabState.list),
                                        itemCount: tabState.list.length,
                                        controller: _pageController,
                                        onPageChanged: (index) {
                                          _tabChangeFromPage = true;
                                          _subTabController?.index = index;
                                        },
                                        itemBuilder: (context, index) {
                                          return ArticleList(
                                              key: pageKeys[index],
                                              cat: tabState.list[index]);
                                        }),
                                  ),
                                ],
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
