import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/app/hot_word_bloc.dart';
import 'package:wanandroid/base/base_state.dart';
import 'package:wanandroid/base/base_view_model_provider.dart';
import 'package:wanandroid/component/base_load_more_view_builder.dart';
import 'package:wanandroid/component/item_article.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/bean/bean.dart';
import 'package:wanandroid/event/events.dart';
import 'package:wanandroid/main.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/util/widget_utils.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';
import 'package:wanandroid/widget/page_indicator.dart';
import 'package:wanandroid/widget/pager_view_ext.dart';
import 'package:wanandroid/widget/refresh_indicator_fix.dart';

import '../../r.dart';
import 'home_bloc.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<HomePage>
    with AutomaticKeepAliveClientMixin, BaseStateMixin {
  @override
  bool get wantKeepAlive => true;

  HomeBloc _bloc;

  final GlobalKey<RefreshIndicatorFixState> _refreshIndicatorKey = GlobalKey();

  ViewPagerController _pageControllerExt;

  ScrollController _scrollController;

  bool hotWordRefreshed = false;

  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc();
    onEvent<MainTabReTapEvent>((e) {
      if (e.index == 0) {
        handleMainTabRepeatTap();
      }
    });
    _scrollController = ScrollController();
  }

  @override
  void afterInitState() {
    super.afterInitState();
    Provider.of<HotWordBloc>(context).refresh();
  }

  void handleMainTabRepeatTap() {
    if (_bloc.state.value == StateValue.Success) {
      if (_scrollController.offset == 0) {
        EventBus.post(MainTabShowRefreshEvent(0, true));
        _refreshIndicatorKey.currentState.show().whenComplete(() {
          EventBus.post(MainTabShowRefreshEvent(0, false));
        });
      } else {
        scrollToTop(_scrollController);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseBlocProvider<HomeBloc>(
      viewModelBuilder: (context) {
        return _bloc;
      },
      child: Consumer<HomeBloc>(
        builder: (context, bloc, _) {
          return Semantics(
            child: Material(
              color: MyApp.getTheme(context).backgroundColor,
              child: Column(
                children: <Widget>[
                  buildTopBar(context, bloc),
                  Expanded(
                    child: ValueListenableBuilder<StateValue>(
                      valueListenable: bloc.state,
                      builder: (context, state, __) {
                        return MultiStateWidget(
                          state: state,
                          onPressedRetry: bloc.retry,
                          successBuilder: (context) =>
                              buildContent(context, bloc),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTopBar(BuildContext context, HomeBloc bloc) {
    return DecoratedBox(
      decoration: BoxDecoration(color: MyApp.getTheme(context).primaryColor),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizeW(16)),
          constraints: BoxConstraints.expand(height: sizeW(50)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage(R.assetsImgLogo),
                height: sizeW(30),
                fit: BoxFit.fitHeight,
                color: MyApp.getTheme(context).appBarTextIconColor,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.SEARCH);
                  },
                  child: Container(
                    height: sizeW(32),
                    padding: EdgeInsets.symmetric(horizontal: sizeW(8)),
                    margin: EdgeInsets.only(left: sizeW(16)),
                    decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(sizeW(4))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.search,
                            color: MyApp.getTheme(context)
                                .textColorPrimaryInverse),
                        ValueListenableBuilder<List<HotWordEntity>>(
                          valueListenable:
                              Provider.of<HotWordBloc>(context).hotWordList,
                          builder: (context, list, _) {
                            String wordString =
                                list.map((e) => e.name).toList().join(",");
                            return Expanded(
                              child: Text(
                                "${list.isEmpty ? "搜索" : wordString}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: MyApp.getTheme(context)
                                        .textColorPrimaryInverse,
                                    fontSize: sizeW(14)),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context, HomeBloc bloc) {
    return RefreshIndicatorFix(
      key: _refreshIndicatorKey,
      displacement: sizeW(40),
      onRefresh: bloc.refresh,
      child: ValueListenableBuilder<List<ArticleEntity>>(
          valueListenable: bloc.list,
          builder: (context, list, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                  color: MyApp.getTheme(context).listBackgroundColor),
              child: LoadMoreListView(
                padding: EdgeInsets.zero,
                scrollController: _scrollController,
                itemCount: list.length + 1,
                loadMoreCallback: () {
                  return bloc.loadMore();
                },
                separatorBuilder: (c, index) => SizedBox(
                  height: sizeW(10),
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return buildBanner(bloc);
                  }
                  var item = list[index - 1];
                  return Container(
                      margin: EdgeInsets.symmetric(horizontal: sizeW(12)),
                      child: ArticleItem(item, showFlag: true));
                },
                loadMoreViewBuilder: createBaseLoadMoreViewBuilder(),
              ),
            );
          }),
    );
  }

  Widget buildBanner(HomeBloc bloc) {
    return Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.only(top: sizeW(16)),
          child: AspectRatio(
              aspectRatio: 2.2,
              child: Stack(children: <Widget>[
                ChangeNotifierProvider.value(
                    value: bloc.bannerNotifier,
                    child:
                        Consumer<ChangeNotifier>(builder: (context, __, ___) {
                      _pageControllerExt = ViewPagerController(
                          itemCount: bloc.bannerList.length,
                          cycle: true,
                          initialPage: bloc.bannerIndex);
                      return ViewPager(
                          key: ObjectKey(bloc.bannerList),
                          autoTurningTime: 5000,
                          onPageChanged: bloc.bannerChanged,
                          controller: _pageControllerExt,
                          itemBuilder: (context, index) {
                            BannerEntity item = bloc.bannerList[index];
                            return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, Routes.WEB,
                                      arguments: {
                                        Routes.WEB_ARG_URL: item.url
                                      });
                                },
                                child: Semantics(
                                    button: false,
                                    label: item.title,
                                    child: ExcludeSemantics(
                                        child: Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: sizeW(14)),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        sizeW(8)),
                                                child: CachedNetworkImage(
                                                    imageUrl: item.imagePath,
                                                    fit: BoxFit.cover))))));
                          });
                    }))
              ]))),
      Padding(
          padding: EdgeInsets.only(top: sizeW(8)),
          child: ChangeNotifierProvider.value(
              value: bloc.bannerIndicatorNotifier,
              child: Consumer<ChangeNotifier>(builder: (_, __, ___) {
                return Center(
                    child: PageIndicator(
                        itemCount: bloc.bannerList.length,
                        currentItem: bloc.bannerIndex,
                        margin: sizeW(8),
                        itemBuilder: (context, index, select) {
                          return Container(
                              width: sizeW(16),
                              height: sizeW(4),
                              decoration: BoxDecoration(
                                  color: select
                                      ? MyApp.getTheme(context)
                                          .pageIndicatorActiveColor
                                      : MyApp.getTheme(context)
                                          .pageIndicatorNormalColor,
                                  borderRadius:
                                      BorderRadius.circular(sizeW(2))));
                        }));
              })))
    ]);
  }
}
