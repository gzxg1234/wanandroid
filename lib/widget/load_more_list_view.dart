import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef Widget LoadMoreViewBuilder(BuildContext context, LoadMoreState state);
typedef Future<LoadMoreState> LoadMoreCallback();

///封装实现加载更多ListView
class LoadMoreListView extends StatefulWidget {
  final int itemCount;
  final LoadMoreViewBuilder loadMoreViewBuilder;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final LoadMoreCallback loadMoreCallback;
  final IndexedWidgetBuilder separatorBuilder;
  final bool hasMore;
  final ScrollPhysics physics;
  final ScrollController scrollController;
  final Widget emptyView;

  const LoadMoreListView(
      {Key key,
      @required this.itemCount,
      @required this.loadMoreViewBuilder,
      @required this.itemBuilder,
      this.scrollController,
      this.loadMoreCallback,
      this.hasMore = true,
      this.padding,
      this.emptyView,
      this.separatorBuilder,
      this.physics})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoadMoreListViewState();
  }
}

enum LoadMoreState {
  ///正常状态
  Normal,

  ///错误状态
  Error,

  ///加载结束状态
  End,
}

class _LoadMoreListViewState extends State<LoadMoreListView> {
  LoadMoreState state;

  bool loading = false;

  ScrollController _scrollController;

  GlobalKey _moreViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    state = widget.hasMore ? LoadMoreState.Normal : LoadMoreState.End;
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollChanged);
  }

  void _scrollChanged() {
    if (!loading &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                (_moreViewKey.currentContext?.size?.height??0) &&
        state == LoadMoreState.Normal) {
      _loadMore();
    }
  }

  @override
  void didUpdateWidget(LoadMoreListView oldWidget) {
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_scrollChanged);
      _setupScrollListener();
    }
    if (oldWidget.hasMore != widget.hasMore) {
      loading = false;
      state = widget.hasMore ? LoadMoreState.Normal : LoadMoreState.End;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _loadMore() {
    if (widget.loadMoreCallback != null) {
      loading = true;
      Future<LoadMoreState> future = widget.loadMoreCallback();
      future.then((result) {
        setState(() {
          this.state = result;
          loading = false;
        });
      }).catchError((e) {
        setState(() {
          state = LoadMoreState.Error;
          loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool enableLoadMore = widget.loadMoreCallback != null;
    return (widget.itemCount == 0 && widget.emptyView != null)
        ? CustomScrollView(physics: widget.physics, slivers: <Widget>[
            SliverFillViewport(
                delegate: SliverChildListDelegate([widget.emptyView]))
          ])
        : ListView.separated(
            controller: _scrollController,
            physics: widget.physics,
            separatorBuilder:
                widget.separatorBuilder ?? (context, index) => Offstage(),
            padding: widget.padding,
            itemCount: enableLoadMore ? widget.itemCount + 1 : widget.itemCount,
            itemBuilder: (context, index) {
              if (enableLoadMore) {
                if (index == widget.itemCount) {
                  Widget child = widget.loadMoreViewBuilder(context, state);
                  if (state == LoadMoreState.Error) {
                    child = GestureDetector(
                        key: _moreViewKey,
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            state = LoadMoreState.Normal;
                            _loadMore();
                          });
                        },
                        child: child);
                  } else {
                    child = Container(key: _moreViewKey, child: child);
                  }
                  return child;
                }
              }
              return widget.itemBuilder(context, index);
            },
          );
  }
}
