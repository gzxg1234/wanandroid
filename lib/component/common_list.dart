import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/base_widget/base_load_more_view_builder.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/bloc/builders.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/util/utils.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';

typedef Widget ItemBuilder<T>(BuildContext context, T item, int index);
typedef Future<PageBean<T>> DataProvider<T>(int page);

class PageBean<T> {
  List<T> data;

  bool hasMore;

  PageBean(this.data, this.hasMore);
}

class CommonList<T> extends StatefulWidget {
  final DataProvider<T> dataProvider;
  final ItemBuilder widgetBuilder;
  final List<Widget> headers;
  final int startPage;
  final IndexedWidgetBuilder separatorBuilder;
  final EdgeInsetsGeometry padding;
  final ScrollController scrollController;

  CommonList(
      {Key key,
      @required this.dataProvider,
      @required this.widgetBuilder,
      this.headers,
      this.startPage = 0,
      this.scrollController,
      this.separatorBuilder,
      this.padding})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CommonListState<T>();
  }
}

class CommonListState<T> extends State<CommonList<T>> {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);

  ValueNotifier<List<T>> _list = ValueNotifier([]);

  ValueNotifier<bool> _hasMore = ValueNotifier(true);

  int _page;

  int get headersLength => widget.headers?.length ?? 0;

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  Future<LoadMoreState> loadMore() async {
    return _loadData(_page + 1, false);
  }

  Future<LoadMoreState> _loadData(int page, bool reload) async {
    if (reload) {
      _state.value = StateValue.Loading;
    }

    PageBean<T> pageData;
    try {
      pageData = await widget.dataProvider(page);
    } catch (e) {
      Utils.toastError(e, "加载失败");
      if (reload) {
        _state.value = StateValue.Error;
      }
      return LoadMoreState.Error;
    }
    _page = page;

    if (!pageData.hasMore && reload) {
      _hasMore.value = false;
    }

    if (page == widget.startPage) {
      _list.value = pageData.data;
    } else {
      _list.value = []..addAll(_list.value)..addAll(pageData.data);
    }

    if (reload) {
      _state.value = StateValue.Success;
    }

    return pageData.hasMore ? LoadMoreState.Normal : LoadMoreState.End;
  }

  Future<void> _refreshData() async {
    await _loadData(widget.startPage, false);
  }

  void _initData() {
    _loadData(widget.startPage, true);
  }

  void refresh() {
    _refreshIndicatorKey.currentState.show();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _page = widget.startPage - 1;
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ValueListenableBuilder<StateValue>(
        valueListenable: _state,
        builder: (context, state, __) {
          return MultiStateWidget(
              state: state,
              onPressedRetry: _initData,
              successBuilder: (context) {
                return RefreshIndicator(
                  displacement: size(40),
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshData,
                  child: MultiValueListenableBuilder(
                      valueListenableList: [_list, _hasMore],
                      builder: (context, values, _) {
                        print(values[1]);
                        return LoadMoreListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: widget.padding,
                          itemCount: values[0].length + headersLength,
                          hasMore: values[1],
                          scrollController: widget.scrollController,
                          loadMoreCallback: loadMore,
                          separatorBuilder: widget.separatorBuilder,
                          itemBuilder: (context, index) {
                            if (index < headersLength) {
                              return widget.headers[index];
                            }
                            index -= headersLength;
                            return widget.widgetBuilder(
                                context, values[0][index], index);
                          },
                          loadMoreViewBuilder: createBaseLoadMoreViewBuilder(),
                        );
                      }),
                );
              });
        });
  }
}