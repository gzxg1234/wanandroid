import 'package:flutter/material.dart';
import 'package:wanandroid/base/base_page.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/bloc/builders.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/bean/banner_entity.dart';
import 'package:wanandroid/util/size_adapter.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';
import 'package:wanandroid/widget/page_indicator.dart';
import 'package:wanandroid/widget/pager_view_ext.dart';

import 'home_bloc.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseBlocProvider(
      blocBuilder: (context) {
        return HomeBloc();
      },
      child: BlocConsumer<HomeBloc>(
        builder: (c, bloc) {
          return Material(
            child: ValueListenableBuilder<StateValue>(
              valueListenable: bloc.state,
              builder: (_, v, __) {
                return MultiStateWidget(
                  state: v,
                  onPressedRetry: bloc.retry,
                  successChild: buildContent(bloc),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildContent(HomeBloc bloc) {
    return Column(
      children: <Widget>[
        AppBar(
          leading: Icon(Icons.menu),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: bloc.refresh,
            child: ValueListenableBuilder<List<ArticleEntity>>(
                valueListenable: bloc.list,
                builder: (context, v, _) {
                  return LoadMoreListView(
                    padding: EdgeInsets.zero,
                    itemCount: v.length+1,
                    loadMoreCallback: () {
                      return bloc.loadMore();
                    },
                    itemBuilder: (context, index) {
                      if(index==0){
                        return buildBanner(bloc);
                      }
                      return Container(
                          height: $size(40),
                          width: double.infinity,
                          child: Text(bloc.list.value[index-1].title));
                    },
                    loadMoreViewBuilder: (context, state) {
                      if (state == LoadMoreState.Error) {
                        return Container(
                          color: Color(0xffeeeeee),
                          height: $size(60),
                          child: Center(child: Text("加载失败，点击重新加载")),
                        );
                      }
                      if (state == LoadMoreState.End) {
                        return Container(
                          color: Color(0xffeeeeee),
                          height: $size(60),
                          child: Center(child: Text("没有更多数据啦~")),
                        );
                      }
                      return Container(
                        color: Color(0xffeeeeee),
                        height: $size(60),
                        child: Center(child: RefreshProgressIndicator()),
                      );
                    },
                  );
                }),
          ),
        ),
      ],
    );
  }

  Widget buildBanner(HomeBloc bloc) {
    return Padding(
      padding: EdgeInsets.only(top: $size(16)),
      child: AspectRatio(
        aspectRatio: 2.2,
        child: Stack(
          children: <Widget>[
            ValueListenableBuilder<List<BannerEntity>>(
              valueListenable: bloc.bannerData,
              builder: (context, value, child) {
                return PageViewExt.builder(
                  cycle: true,
                  onPageChanged: bloc.bannerChanged,
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: EdgeInsets.symmetric(horizontal: $size(14)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular($size(8)),
                          child: Image.network(
                            value[index].imagePath,
                            fit: BoxFit.cover,
                          ),
                        ));
                  },
                );
              },
            ),
            Positioned(
              bottom: $size(8),
              left: 0,
              right: 0,
              child: MultiValueListenableBuilder(
                valueListenableList: [bloc.bannerData, bloc.currentBanner],
                builder: (context, values, child) {
                  return Center(
                    child: PageIndicator(
                      itemCount: values[0].length,
                      currentItem: values[1],
                      margin: $size(8),
                      itemBuilder: (context, index, select) {
                        return Container(
                          width: $size(16),
                          height: $size(8),
                          decoration: BoxDecoration(
                              color: select
                                  ? Theme.of(context).primaryColor
                                  : Color(0xffeeeeee),
                              borderRadius: BorderRadius.circular($size(4))),
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
