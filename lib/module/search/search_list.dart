import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/component/common_list.dart';
import 'package:wanandroid/component/item_article.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/repo.dart';
import 'package:wanandroid/main.dart';
import 'package:wanandroid/util/auto_size.dart';

class SearchList extends StatefulWidget {
  final String word;

  const SearchList({Key key, this.word}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SearchListState();
  }
}

class SearchListState extends State<SearchList>
    with AutomaticKeepAliveClientMixin<SearchList> {
  @override
  bool get wantKeepAlive => true;

  ApiClient _repo = ApiClient();

  ScrollController _scrollController = ScrollController();

  GlobalObjectKey<CommonListState> _commonListKey;

  @override
  void initState() {
    super.initState();
    _commonListKey = GlobalObjectKey(widget.word);
    _repo = ApiClient();
  }

  @override
  void didUpdateWidget(SearchList oldWidget) {
    if (oldWidget.word != widget.word) {
      _commonListKey = GlobalObjectKey(widget.word);
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
          return _repo.search(widget.word, page).then((e) {
            return PageBean(e.datas, !e.over);
          });
        },
        separatorBuilder: (_, index) {
          return SizedBox(height: sizeW(8));
        },
        widgetBuilder: (BuildContext context, item, int index) {
          return ArticleItem(item,parseTitle: true);
        },
      ),
    );
  }
}
