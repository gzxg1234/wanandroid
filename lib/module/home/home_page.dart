import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wanandroid/app/app.dart';
import 'package:wanandroid/app/app_bloc.dart';
import 'package:wanandroid/base/base_page.dart';
import 'package:wanandroid/base_widget/base_load_more_view_builder.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/bloc/builders.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';
import 'package:wanandroid/widget/page_indicator.dart';
import 'package:wanandroid/widget/pager_view_ext.dart';

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
  Widget build(BuildContext context) {
    super.build(context);
    return BaseBlocProvider(
      blocBuilder: (context) {
        return HomeBloc();
      },
      child: BlocConsumer<HomeBloc>(
        builder: (context, bloc) {
          return Material(
            color: BlocProvider.of<AppBloc>(context).theme.backgroundColor,
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
          padding: EdgeInsets.symmetric(horizontal: 16),
          constraints: BoxConstraints.expand(height: 50),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "玩安卓",
                style: TextStyle(
                    color: MyApp.getTheme(context).textColorPrimaryInverse,
                    fontSize: 16),
              ),
              Expanded(
                child: Container(
                  height: 32,
                  margin: EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.search,
                          color:
                              MyApp.getTheme(context).textColorPrimaryInverse),
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
      displacement: 40,
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
                height: 10,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return buildBanner(bloc);
                }
                AppBloc appBloc = BlocProvider.of<AppBloc>(context);
                var item = list[index - 1];
                return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    color: appBloc.theme.cardColor,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: appBloc.theme.textColorPrimary),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: <Widget>[
                                  Text("作者:${item.author}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: appBloc
                                              .theme.textColorSecondary)),
                                  Container(
                                    margin: EdgeInsets.only(left: 16),
                                    child: Text("分类:${item.chapterName}",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: appBloc
                                                .theme.textColorSecondary)),
                                  ),
                                  Expanded(
                                    child: Text(item.niceDate,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: appBloc
                                                .theme.textColorSecondary)),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ));
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
          padding: EdgeInsets.only(top: 16),
          child: AspectRatio(
            aspectRatio: 2.2,
            child: Stack(
              children: <Widget>[
                MultiValueListenableBuilder(
                    valueListenableList: [bloc.bannerData, bloc.currentBanner],
                    builder: (context, values, child) {
                      return ViewPager(
                        cycle: true,
                        autoTurningTime: 5000,
                        onPageChanged: bloc.bannerChanged,
                        itemCount: values[0].length,
                        controller: PageControllerExt(
                            cycle: true, itemCount: values[0].length),
                        itemBuilder: (context, index) {
                          return Container(
                              margin: EdgeInsets.symmetric(horizontal: 14),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                    imageUrl: values[0][index].imagePath,
                                    fit: BoxFit.cover),
                              ));
                        },
                      );
                    })
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: MultiValueListenableBuilder(
            valueListenableList: [bloc.bannerData, bloc.currentBanner],
            builder: (context, values, child) {
              return Center(
                child: PageIndicator(
                  itemCount: values[0].length,
                  currentItem: values[1],
                  margin: 8,
                  itemBuilder: (context, index, select) {
                    return Container(
                      width: 16,
                      height: 4,
                      decoration: BoxDecoration(
                          color: select
                              ? Theme.of(context).primaryColor
                              : Color(0xffeeeeee),
                          borderRadius: BorderRadius.circular(2)),
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
