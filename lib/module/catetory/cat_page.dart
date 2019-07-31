import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/app/app.dart';
import 'package:wanandroid/base/base_bloc_provider.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/bloc/builders.dart';
import 'package:wanandroid/component/more_tab_window.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/util/auto_size.dart';

import 'article_list.dart';
import 'cat_bloc.dart';

class CatPage extends StatefulWidget {
  CatPage({Key key}) : super(key: key);

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

  CatBloc _catBloc;

  bool _tabChangeFromPage = false;

  TabController _tabController;

  TabController _subTabController;

  PageController _pageController;

  MoreTabWindow _moreTabWindow;

  GlobalKey _tabBarKey = GlobalKey();

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  @override
  void dispose() {
    _moreTabWindow?.dismiss();
    _tabController?.dispose();
    _subTabController?.dispose();
    super.dispose();
  }

  void handleMainTabRepeatTap() {
    if (_catBloc.state.value == StateValue.Success) {
      _refreshIndicatorKey.currentState.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseBlocProvider<CatBloc>(
      blocBuilder: (BuildContext context) {
        return _catBloc = CatBloc();
      },
      child: BlocConsumer<CatBloc>(
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
                    child: Column(
                      children: <Widget>[
                        ValueListenableBuilder<List<CategoryEntity>>(
                          valueListenable: bloc.catList,
                          builder: (context, list, _) {
                            _tabController?.dispose();
                            _tabController = TabController(
                                length: list.length,
                                vsync: this,
                                initialIndex: bloc.currentCatIndex.value);
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
                            );
                          },
                        ),
                        Expanded(
                          child: MultiValueListenableBuilder(
                            valueListenableList: [
                              bloc.subCatList,
                              bloc.currentSubCatIndex
                            ],
                            builder: (context, values, _) {
                              final List<CategoryEntity> subCatList = values[0];
                              final int index = values[1];
                              _subTabController = TabController(
                                  length: subCatList.length,
                                  vsync: this,
                                  initialIndex: index);
                              _subTabController.addListener(() {
                                bloc.setSubCatPosition(_subTabController.index);
                                if (!_tabChangeFromPage) {
                                  _pageController
                                      .jumpToPage(_subTabController.index);
                                } else {
                                  _tabChangeFromPage = false;
                                }
                              });

                              _pageController = PageController(
                                  initialPage: index, keepPage: false);
                              List<GlobalKey<dynamic>> pageKeys =
                                  List.generate(subCatList.length, (i) {
                                return GlobalKey();
                              });

                              return Column(
                                children: <Widget>[
                                  Container(
                                      color:
                                          MyApp.getTheme(context).primaryColor,
                                      width: double.infinity,
                                      child: TabBar(
                                          key: ObjectKey(subCatList),
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
                                              TextStyle(fontSize: size(14)),
                                          labelStyle:
                                              TextStyle(fontSize: size(14)),
                                          tabs: () {
                                            return subCatList
                                                .map((e) => Tab(
                                                      text: e.name,
                                                    ))
                                                .toList();
                                          }())),
                                  Expanded(
                                    child: PageView.builder(
                                        key: ObjectKey(subCatList),
                                        itemCount: bloc.subCatList.value.length,
                                        controller: _pageController,
                                        onPageChanged: (index) {
                                          _tabChangeFromPage = true;
                                          _subTabController?.index = index;
                                        },
                                        itemBuilder: (context, index) {
                                          return ArticleList(
                                              key: pageKeys[index],
                                              cat:
                                                  bloc.subCatList.value[index]);
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

  void _showMoreCat(CatBloc bloc) {
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
