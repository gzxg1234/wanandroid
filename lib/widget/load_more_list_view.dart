import 'package:flutter/cupertino.dart';

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

  const LoadMoreListView(
      {Key key,
      @required this.itemCount,
      @required this.loadMoreViewBuilder,
      @required this.itemBuilder,
      this.scrollController,
      this.loadMoreCallback,
      this.hasMore = true,
      this.padding,
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    state = widget.hasMore ? LoadMoreState.Normal : LoadMoreState.End;
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController?.dispose();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(() {
      if (!loading &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          state == LoadMoreState.Normal) {
        _loadMore();
      }
    });
  }

  @override
  void didUpdateWidget(LoadMoreListView oldWidget) {
    if (oldWidget.scrollController != widget.scrollController) {
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
    // TODO: implement build
    bool enableLoadMore = widget.loadMoreCallback != null;
    return ListView.separated(
      controller: _scrollController,
      physics: widget.physics,
      separatorBuilder:
          widget.separatorBuilder ?? (context, index) => Offstage(),
      padding: widget.padding,
      itemCount: enableLoadMore ? widget.itemCount + 1 : widget.itemCount,
      itemBuilder: (context, index) {
        if (enableLoadMore) {
          if (index == widget.itemCount) {
            if (state == LoadMoreState.Error) {
              return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      state = LoadMoreState.Normal;
                      _loadMore();
                    });
                  },
                  child: widget.loadMoreViewBuilder(context, state));
            }
            return widget.loadMoreViewBuilder(context, state);
          }
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}
