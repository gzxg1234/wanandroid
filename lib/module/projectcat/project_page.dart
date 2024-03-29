import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/base/base_state.dart';
import 'package:wanandroid/base/base_view_model_provider.dart';
import 'package:wanandroid/component/common_list.dart';
import 'package:wanandroid/component/item_article.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/component/tab_pager.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/repo.dart';
import 'package:wanandroid/event/events.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/util/widget_utils.dart';
import 'package:wanandroid/widget/keep_alive.dart';
import 'package:wanandroid/widget/refresh_indicator_fix.dart';

import '../../main.dart';
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
    with
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin,
        BaseStateMixin {
  @override
  bool get wantKeepAlive => true;

  GlobalKey<RefreshIndicatorFixState> _refreshIndicatorKey = GlobalKey();

  List<GlobalKey<CommonListState>> pageKeys;
  List<ScrollController> scrollControllers;

  ProjectBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ProjectBloc();
    onEvent<MainTabReTapEvent>((e) {
      if (e.index == 2) {
        handleMainTabRepeatTap();
      }
    });
    _bloc.catList.addListener(() {
      pageKeys = List.generate(_bloc.catList.value.length,
          (i) => GlobalObjectKey(_bloc.catList.value[i]));
      scrollControllers =
          List.generate(_bloc.catList.value.length, (i) => ScrollController());
    });
  }

  void handleMainTabRepeatTap() {
    if (_bloc.state.value == StateValue.Success) {
      EventBus.post(MainTabShowRefreshEvent(2, true));
      _refreshIndicatorKey.currentState.show().whenComplete(() {
        EventBus.post(MainTabShowRefreshEvent(2, false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseBlocProvider<ProjectBloc>(
        viewModelBuilder: (BuildContext context) {
      return _bloc;
    }, child: Consumer<ProjectBloc>(builder: (context, bloc, _) {
      return ValueListenableBuilder<StateValue>(
          valueListenable: bloc.state,
          builder: (context, state, _) {
            return MultiStateWidget(
                state: state,
                onPressedRetry: bloc.fetchCategoryData,
                successBuilder: (context) {
                  return ValueListenableBuilder<List<CategoryEntity>>(
                      valueListenable: bloc.catList,
                      child: Offstage(),
                      builder: (context, catList, empty) {
                        if (catList == null) {
                          return empty;
                        }
                        return RefreshIndicatorFix(
                            key: _refreshIndicatorKey,
                            onRefresh: () => bloc.fetchCategoryData(false),
                            child: Column(children: <Widget>[
                              Container(
                                  color: MyApp.getTheme(context).primaryColor,
                                  height: MediaQuery.of(context).padding.top),
                              Expanded(
                                  child: TabPager(
                                      key: ObjectKey(catList),
                                      tabs: catList.map((e) => e.name).toList(),
                                      onTabReTap: (index) {
                                        if (scrollControllers[index].offset ==
                                            0) {
                                          pageKeys[index]
                                              .currentState
                                              ?.refresh();
                                        } else {
                                          scrollToTop(scrollControllers[index]);
                                        }
                                      },
                                      pageBuilder: (_, index) {
                                        final int id = catList[index].id;
                                        return KeepAliveContainer(
                                            child: CommonList<ArticleEntity>(
                                                key: pageKeys[index],
                                                padding:
                                                    EdgeInsets.all(sizeW(12)),
                                                scrollController:
                                                    scrollControllers[index],
                                                startPage: 1,
                                                dataProvider: (page) {
                                                  if (id == null) {
                                                    return ApiClient
                                                            .getNewsProjectList(
                                                                page,
                                                                cancelToken)
                                                        .then((e) {
                                                      return PageBean(
                                                          e.datas, !e.over);
                                                    });
                                                  }
                                                  return ApiClient
                                                          .getProjectList(page,
                                                              id, cancelToken)
                                                      .then((e) {
                                                    return PageBean(
                                                        e.datas, !e.over);
                                                  });
                                                },
                                                separatorBuilder: (_, index) {
                                                  return SizedBox(
                                                      height: sizeW(8));
                                                },
                                                itemBuilder:
                                                    (BuildContext context, item,
                                                        int index) {
                                                  return ArticleItem(item);
                                                }));
                                      }))
                            ]));
                      });
                });
          });
    }));
  }
}
