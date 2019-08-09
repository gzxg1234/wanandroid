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
import 'package:wanandroid/event/events.dart';
import 'package:wanandroid/module/woa/wx_bloc.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/util/widget_utils.dart';
import 'package:wanandroid/widget/keep_alive.dart';
import 'package:wanandroid/widget/refresh_indicator_fix.dart';

import '../../main.dart';

class WxPage extends StatefulWidget {
  WxPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<WxPage>
    with
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin,
        BaseStateMixin {
  @override
  bool get wantKeepAlive => true;

  GlobalKey<RefreshIndicatorFixState> _refreshIndicatorKey = GlobalKey();

  List<GlobalKey<CommonListState>> pageKeys;
  List<ScrollController> scrollControllers;

  WxBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = WxBloc();
    _bloc.catList.addListener(() {
      pageKeys = List.generate(_bloc.catList.value.length,
          (i) => GlobalObjectKey(_bloc.catList.value[i]));
      scrollControllers =
          List.generate(_bloc.catList.value.length, (i) => ScrollController());
    });
    onEvent<MainTabReTapEvent>((e) {
      if (e.index == 3) {
        handleMainTabRepeatTap();
      }
    });
  }

  void handleMainTabRepeatTap() {
    if (_bloc.state.value == StateValue.Success) {
      EventBus.post(MainTabShowRefreshEvent(3, true));
      _refreshIndicatorKey.currentState.show().whenComplete(() {
        EventBus.post(MainTabShowRefreshEvent(3, false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseBlocProvider<WxBloc>(
        viewModelBuilder: (BuildContext context) {
      return _bloc;
    }, child: Consumer<WxBloc>(builder: (context, bloc, _) {
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
                      builder: (context, catList, _) {
                        print(catList);
                        if (catList == null) {
                          return _;
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
                                      onTabChange: (index) {},
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
                                                dataProvider: (page) =>
                                                    bloc.fetchList(page, id),
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
