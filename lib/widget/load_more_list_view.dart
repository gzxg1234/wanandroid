import 'package:flutter/cupertino.dart';

typedef Widget LoadMoreViewBuilder(BuildContext context, LoadMoreState state);
typedef Future<LoadMoreState> LoadMoreCallback();

class LoadMoreListView extends StatefulWidget {
  final int itemCount;
  final LoadMoreViewBuilder loadMoreViewBuilder;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final LoadMoreCallback loadMoreCallback;

  const LoadMoreListView(
      {Key key,
      @required this.itemCount,
      @required this.loadMoreViewBuilder,
      @required this.itemBuilder,
      this.loadMoreCallback, this.padding})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoadMoreListViewState();
  }
}

enum LoadMoreState {
  Completed,
  Error,
  End,
}

class _LoadMoreListViewState extends State<LoadMoreListView> {
  LoadMoreState state = LoadMoreState.Completed;
  bool loading = false;

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
    return ListView.builder(
      padding: widget.padding,
      itemCount: enableLoadMore ? widget.itemCount + 1 : widget.itemCount,
      itemBuilder: (context, index) {
        if (enableLoadMore) {
          if (index == widget.itemCount) {
            if (state == LoadMoreState.Error) {
              return GestureDetector(
                  onTap: () {
                    setState(() {
                      state = LoadMoreState.Completed;
                      _loadMore();
                    });
                  },
                  child: widget.loadMoreViewBuilder(context, state));
            }
            return widget.loadMoreViewBuilder(context, state);
          }
          if (state == LoadMoreState.Completed &&
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
