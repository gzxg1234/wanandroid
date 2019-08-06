import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/base/builders.dart';
import 'package:wanandroid/component/base_load_more_view_builder.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/util/utils.dart';
import 'package:wanandroid/util/widget_utils.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';
import 'package:wanandroid/widget/refresh_indicator_fix.dart';

import '../main.dart';
import '../r.dart';

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

  GlobalKey<RefreshIndicatorFixState> _refreshIndicatorKey = GlobalKey();

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
      showToast(context: context, msg: Utils.getErrorMsg(e, "加载失败"));
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
                return RefreshIndicatorFix(
                  displacement: sizeW(40),
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshData,
                  child: MultiValueListenableBuilder(
                      valueListenableList: [_list, _hasMore],
                      builder: (context, values, _) {
                        return LoadMoreListView(
                          emptyView: Empty(),
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

class Empty extends StatelessWidget {
  const Empty({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      constraints: BoxConstraints.expand(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            R.assetsImgIcEmpty,
            color: MyApp.getTheme(context).textColorSecondary,
            width: sizeW(100),
            fit: BoxFit.fitWidth,
          ),
          Container(
            margin: EdgeInsets.only(top: sizeW(16)),
            child: Text(
              "木有数据~",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: MyApp.getTheme(context).textColorSecondary,
                  fontSize: sizeW(14)),
            ),
          ),
          //整体往上移动一丢丢
          SizedBox(height: sizeW(50))
        ],
      ),
    );
  }
}
