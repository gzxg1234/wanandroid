import 'package:flutter/cupertino.dart';

typedef Widget LoadMoreViewBuilder(BuildContext context, LoadMoreState state);
typedef Future<LoadMoreState> LoadMoreCallback();

class LoadMoreListView extends StatefulWidget {
  final int itemCount;
  final LoadMoreViewBuilder loadMoreViewBuilder;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final LoadMoreCallback loadMoreCallback;
  final IndexedWidgetBuilder separatorBuilder;
  final bool hasMore;
  final ScrollPhysics physics;

  const LoadMoreListView(
      {Key key,
      @required this.itemCount,
      @required this.loadMoreViewBuilder,
      @required this.itemBuilder,
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
  Normal,
  Error,
  End,
}

class _LoadMoreListViewState extends State<LoadMoreListView> {
  LoadMoreState state;

  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    state = widget.hasMore ? LoadMoreState.Normal : LoadMoreState.End;
  }

  @override
  void didUpdateWidget(LoadMoreListView oldWidget) {
    if (oldWidget.hasMore != widget.hasMore) {
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
      controller: ScrollController(),
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
          if (state == LoadMoreState.Normal &&
              !loading &&
              index == widget.itemCount - 1) {
            _loadMore();
          }
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}
