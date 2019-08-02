import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/base/base_view_model_provider.dart';
import 'package:wanandroid/component/more_tab_window.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/event/events.dart';
import 'package:wanandroid/module/projectcat/project_list.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/refresh_indicator_fix.dart';
import 'package:wanandroid/widget/rotation_view.dart';

import '../../main.dart';
import 'project_vm.dart';

class ProjectPage extends StatefulWidget {
  ProjectPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<ProjectPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  GlobalKey _tabBarKey;
  GlobalKey<RotationViewState> _dropDownButtonKey = GlobalKey();
  GlobalKey<RefreshIndicatorFixState> _refreshIndicatorKey = GlobalKey();

  List<GlobalKey<ProjectListState>> pageKeys = [];

  ProjectVM _bloc;
  TabController _tabController;
  PageController _pageController;
  bool _tabChangeFromPage = false;
  MoreTabWindow _moreTabWindow;

  StreamSubscription<MainTabReTapEvent> eventSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 0);
    _pageController = PageController();
    eventSubscription = EventBus.on<MainTabReTapEvent>().listen((e) {
      if (e.index == 2) {
        handleMainTabRepeatTap();
      }
    });
  }

  @override
  void dispose() {
    eventSubscription?.cancel();
    _tabController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void handleMainTabRepeatTap() {
    if (_bloc.state.value == StateValue.Success) {
      _refreshIndicatorKey.currentState.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseViewModelProvider<ProjectVM>(
      viewModelBuilder: (BuildContext context) {
        return _bloc = ProjectVM();
      },
      child: Consumer<ProjectVM>(
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
                    child: ValueListenableBuilder<ProjectTabState>(
                      valueListenable: bloc.tabState,
                      builder: (context, tabState, _) {
                        pageKeys = List.generate(
                            tabState.list.length, (i) => GlobalKey());
                        _tabController = TabController(
                            vsync: this,
                            length: tabState.list.length,
                            initialIndex: tabState.index);
                        _tabController.addListener(() {
                          bloc.indexChange(_tabController.index);
                          if (!_tabChangeFromPage) {
                            _pageController.jumpToPage(_tabController.index);
                          } else {
                            _tabChangeFromPage = false;
                          }
                        });
                        _pageController =
                            PageController(initialPage: tabState.index);
                        _tabController.index = tabState.index;

                        return Column(
                          children: <Widget>[
                            Container(
                              color: MyApp.getTheme(context).primaryColor,
                              child: SafeArea(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TabBar(
                                        key: _tabBarKey = GlobalKey(),
                                        isScrollable: true,
                                        onTap: (index) {
                                          if (!_tabController.indexIsChanging) {
                                            pageKeys[index]
                                                .currentState
                                                ?.onParentTabTap();
                                          }
                                        },
                                        //是否可以滚动
                                        controller: _tabController,
                                        labelColor: MyApp.getTheme(context)
                                            .tabBarSelectedColor,
                                        unselectedLabelColor:
                                            MyApp.getTheme(context)
                                                .tabBarUnSelectedColor,
                                        labelStyle:
                                            TextStyle(fontSize: size(14)),
                                        tabs: () {
                                          return tabState.list
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
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: PageView.builder(
                                  key: ObjectKey(tabState.list),
                                  itemCount: tabState.list.length,
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    //flag标记防止tab的change又调用page.jumpage
                                    _tabChangeFromPage = true;
                                    _tabController?.index = index;
                                  },
                                  itemBuilder: (context, index) {
                                    print(tabState.list[index].id);
                                    return ProjectList(
                                        key: pageKeys[index],
                                        cat: tabState.list[index]);
                                  }),
                            )
                          ],
                        );
                      },
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

  void _showMoreCat(List<CategoryEntity> list) {
    _moreTabWindow =
        MoreTabWindow(list.map((e) => e.name).toList(), _tabController.index);
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
