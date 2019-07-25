import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';

LoadMoreViewBuilder createBaseLoadMoreViewBuilder() {
  return (context, state) {
    if (state == LoadMoreState.Error) {
      return Container(
        constraints: BoxConstraints.expand(height: size(60)),
        child: Center(child: Text("加载失败，点击重新加载")),
      );
    }
    if (state == LoadMoreState.End) {
      return Container(
        constraints: BoxConstraints.expand(height:size(60)),
        child: Center(child: Text("没有更多数据啦~")),
      );
    }
    return Container(
      constraints: BoxConstraints.expand(height:size(60)),
      child: Center(child: RefreshProgressIndicator()),
    );
  };
}
