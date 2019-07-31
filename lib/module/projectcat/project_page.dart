import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/app/app.dart';
import 'package:wanandroid/base/base_bloc_provider.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/component/more_tab_window.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/module/projectcat/project_list.dart';
import 'package:wanandroid/util/auto_size.dart';

import 'project_bloc.dart';

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
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  ProjectBloc _bloc;
  TabController _tabController;
  PageController _pageController;
  bool _tabChangeFromPage = false;
  GlobalKey _tabBarKey = GlobalKey();
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();
  MoreTabWindow _moreTabWindow;

  @override
  void dispose() {
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
    return BaseBlocProvider<ProjectBloc>(
      blocBuilder: (BuildContext context) {
        return _bloc = ProjectBloc();
      },
      child: BlocConsumer<ProjectBloc>(
        builder: (context, bloc) {
          return ValueListenableBuilder<StateValue>(
            valueListenable: bloc.state,
            builder: (context, state, _) {
              return MultiStateWidget(
                state: state,
                onPressedRetry: bloc.fetchCategoryData,
                successBuilder: (context) {
                  return RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () => bloc.fetchCategoryData(false),
                    child: ValueListenableBuilder<List<CategoryEntity>>(
                      valueListenable: bloc.catList,
                      builder: (context, list, _) {
                        _tabController?.dispose();
                        _tabController =
                            TabController(length: list.length, vsync: this);
                        _tabController.addListener(() {
                          if (!_tabChangeFromPage) {
                            _pageController.jumpToPage(_tabController.index);
                          } else {
                            _tabChangeFromPage = true;
                          }
                        });
                        _pageController =
                            PageController(initialPage: _tabController.index, keepPage: false);

                        List<GlobalKey<ProjectListState>> pageKeys =
                            List.generate(list.length, (i) {
                          return GlobalKey();
                        });
                        return Column(
                          children: <Widget>[
                            Container(
                              color: MyApp.getTheme(context).primaryColor,
                              child: SafeArea(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TabBar(
                                        key: _tabBarKey,
                                        isScrollable: true,
                                        onTap: (index){
                                          if(!_tabController.indexIsChanging){
                                            pageKeys[index].currentState.onParentTabTap();
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
                                            color: MyApp.getTheme(context)
                                                .iconColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: PageView.builder(
                                  key: ObjectKey(list),
                                  itemCount: bloc.catList.value.length,
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    //flag标记防止tab的change又调用page.jumpage
                                    _tabChangeFromPage = false;
                                    _tabController?.index = index;
                                  },
                                  itemBuilder: (context, index) {
                                    return ProjectList(
                                        key: pageKeys[index],
                                        cat: bloc.catList.value[index]);
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

  void _showMoreCat(ProjectBloc bloc) {
    _moreTabWindow = MoreTabWindow(
        bloc.catList.value.map((e) => e.name).toList(), _tabController.index);
    _moreTabWindow
        .showAsDropdown(targetContext: _tabBarKey.currentContext)
        .then((index) {
      if (index != null) {
        _tabController?.index = index;
      }
    });
  }
}
