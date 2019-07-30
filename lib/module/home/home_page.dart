import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wanandroid/app/app.dart';
import 'package:wanandroid/app/hot_word_bloc.dart';
import 'package:wanandroid/base/base_page.dart';
import 'package:wanandroid/base_widget/base_load_more_view_builder.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/bloc/builders.dart';
import 'package:wanandroid/component/item_article.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/bean/bean.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';
import 'package:wanandroid/widget/page_indicator.dart';
import 'package:wanandroid/widget/pager_view_ext.dart';

import '../../r.dart';
import 'home_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      BlocProvider.of<HotWordBloc>(context).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseBlocProvider(
      blocBuilder: (context) {
        return HomeBloc();
      },
      child: BlocConsumer<HomeBloc>(
        builder: (context, bloc) {
          return Material(
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
          padding: EdgeInsets.symmetric(horizontal: size(16)),
          constraints: BoxConstraints.expand(height: size(50)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage(R.assetsImgLogo),
                height: size(30),
                fit: BoxFit.fitHeight,
                color: MyApp.getTheme(context).iconColor,
              ),
              Expanded(
                child: Container(
                  height: size(32),
                  padding: EdgeInsets.symmetric(horizontal: size(8)),
                  margin: EdgeInsets.only(left: size(16)),
                  decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(size(4))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.search,
                          color:
                              MyApp.getTheme(context).textColorPrimaryInverse),
                      ValueListenableBuilder<List<HotWordEntity>>(
                        valueListenable:
                            BlocProvider.of<HotWordBloc>(context).hotWordList,
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
                                  fontSize: size(14)),
                            ),
                          );
                        },
                      )
                    ],
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
    return RefreshIndicator(
      displacement: size(40),
      onRefresh: bloc.refresh,
      child: ValueListenableBuilder<List<ArticleEntity>>(
          valueListenable: bloc.list,
          builder: (context, list, _) {
            return LoadMoreListView(
              padding: EdgeInsets.zero,
              itemCount: list.length + 1,
              loadMoreCallback: () {
                return bloc.loadMore();
              },
              separatorBuilder: (c, index) => SizedBox(
                height: size(10),
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return buildBanner(bloc);
                }
                var item = list[index - 1];
                return Container(
                    margin: EdgeInsets.symmetric(horizontal: size(12)),
                    child: ArticleItem(item));
              },
              loadMoreViewBuilder: createBaseLoadMoreViewBuilder(),
            );
          }),
    );
  }

  Widget buildBanner(HomeBloc bloc) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: size(16)),
          child: AspectRatio(
            aspectRatio: 2.2,
            child: Stack(
              children: <Widget>[
                MultiValueListenableBuilder(
                    valueListenableList: [bloc.bannerData, bloc.bannerIndex],
                    builder: (context, values, child) {
                      PageControllerExt controller = PageControllerExt(
                          initialPage: values[1],
                          cycle: true,
                          itemCount: values[0].length);
                      return ViewPager(
                        key: ObjectKey(values),
                        cycle: true,
                        autoTurningTime: 5000,
                        onPageChanged: bloc.bannerChanged,
                        itemCount: values[0].length,
                        controller: controller,
                        itemBuilder: (context, index) {
                          BannerEntity item = values[0][index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, Routes.WEB,
                                  arguments: {Routes.WEB_ARG_URL: item.url});
                            },
                            child: Container(
                                margin:
                                    EdgeInsets.symmetric(horizontal: size(14)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(size(8)),
                                  child: CachedNetworkImage(
                                      imageUrl: item.imagePath,
                                      fit: BoxFit.cover),
                                )),
                          );
                        },
                      );
                    })
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: size(8)),
          child: MultiValueListenableBuilder(
            valueListenableList: [bloc.bannerData, bloc.bannerIndex],
            builder: (context, values, child) {
              return Center(
                child: PageIndicator(
                  itemCount: values[0].length,
                  currentItem: values[1],
                  margin: size(8),
                  itemBuilder: (context, index, select) {
                    return Container(
                      width: size(16),
                      height: size(4),
                      decoration: BoxDecoration(
                          color: select
                              ? MyApp.getTheme(context).pageIndicatorActiveColor
                              : MyApp.getTheme(context)
                                  .pageIndicatorNormalColor,
                          borderRadius: BorderRadius.circular(size(2))),
                    );
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
