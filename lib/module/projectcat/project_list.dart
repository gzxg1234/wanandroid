import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/app/app.dart';
import 'package:wanandroid/base_widget/base_load_more_view_builder.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';
import 'package:wanandroid/bloc/builders.dart';
import 'package:wanandroid/component/item_project.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';

import 'project_list_bloc.dart';

class ProjectList extends StatefulWidget {
  final CategoryEntity cat;

  const ProjectList({Key key, this.cat}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<ProjectList>
    with AutomaticKeepAliveClientMixin<ProjectList> {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  ArticleListBloc _bloc;

  @override
  void didUpdateWidget(ProjectList oldWidget) {
    // TODO: implement didUpdateWidget
    if (oldWidget.cat != widget.cat) {
      _bloc.updateCatId(widget.cat.id);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<ArticleListBloc>(
      blocBuilder: (_) {
        return _bloc = ArticleListBloc(widget.cat.id);
      },
      child: BlocConsumer<ArticleListBloc>(
        builder: (context, bloc) {
          return Material(
            color: MyApp.getTheme(context).backgroundColor,
            child: ValueListenableBuilder<StateValue>(
              valueListenable: bloc.state,
              builder: (context, state, __) {
                return MultiStateWidget(
                    state: state,
                    onPressedRetry: bloc.retry,
                    successBuilder: (context) {
                      return RefreshIndicator(
                        displacement: size(40),
                        onRefresh: bloc.refresh,
                        child: MultiValueListenableBuilder(
                            valueListenableList: [bloc.list, bloc.hasMore],
                            builder: (context, values, _) {
                              List<ArticleEntity> list = values[0];
                              bool hasMore = values[1];
                              return LoadMoreListView(
                                physics: AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.all(size(12)),
                                itemCount: list.length,
                                loadMoreCallback: () {
                                  return bloc.loadMore();
                                },
                                separatorBuilder: (c, index) => SizedBox(
                                  height: size(10),
                                ),
                                hasMore: hasMore,
                                itemBuilder: (context, index) {
                                  return ProjectItem(list[index]);
                                },
                                loadMoreViewBuilder:
                                    createBaseLoadMoreViewBuilder(),
                              );
                            }),
                      );
                    });
              },
            ),
          );
        },
      ),
    );
  }
}
