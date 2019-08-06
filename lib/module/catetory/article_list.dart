import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/component/common_list.dart';
import 'package:wanandroid/component/item_article.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/repo.dart';
import 'package:wanandroid/main.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/util/widget_utils.dart';

class ArticleList extends StatefulWidget {
  final CategoryEntity cat;

  const ArticleList({Key key, this.cat}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ArticleListState();
  }
}

class ArticleListState extends State<ArticleList>
    with AutomaticKeepAliveClientMixin<ArticleList> {
  @override
  bool get wantKeepAlive => true;

  ApiClient _repo = ApiClient();

  ScrollController _scrollController = ScrollController();

  GlobalObjectKey<CommonListState> _commonListKey;

  @override
  void initState() {
    super.initState();
    _commonListKey = GlobalObjectKey(widget.cat);
    _repo = ApiClient();
  }

  void onParentTabTap() {
    if (_scrollController.offset == 0) {
      _commonListKey.currentState.refresh();
    } else {
      scrollToTop(_scrollController);
    }
  }

  @override
  void didUpdateWidget(ArticleList oldWidget) {
    if (oldWidget.cat != widget.cat) {
      _commonListKey = GlobalObjectKey(widget.cat);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      color: MyApp.getTheme(context).backgroundColor,
      child: CommonList<ArticleEntity>(
        key: _commonListKey,
        padding: EdgeInsets.all(sizeW(12)),
        scrollController: _scrollController,
        startPage: 0,
        dataProvider: (page) {
          return _repo.getArticleList(page, widget.cat.id).then((e) {
            return PageBean(e.datas, !e.over);
          });
        },
        separatorBuilder: (_, index) {
          return SizedBox(height: sizeW(8));
        },
        widgetBuilder: (BuildContext context, item, int index) {
          return ArticleItem(item);
        },
      ),
    );
  }
}
