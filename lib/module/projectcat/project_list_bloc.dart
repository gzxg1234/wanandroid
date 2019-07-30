import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/base_bloc.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/bean/page_data.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';

class ArticleListBloc extends BaseBloc {
  int _catId;

  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);

  ValueNotifier<List<ArticleEntity>> _list = ValueNotifier([]);

  ValueNotifier<bool> _hasMore = ValueNotifier(true);

  ValueListenable<StateValue> get state => _state;

  ValueListenable<List<ArticleEntity>> get list => _list;

  ValueListenable<bool> get hasMore => _hasMore;

  static const int START_PAGE = 1;

  int _page = START_PAGE - 1;

  ArticleListBloc(this._catId);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    retry();
  }

  void updateCatId(int id) {
    _catId = id;
    _list.value = [];
    _page = 0;
    _state.value = StateValue.Loading;
    retry();
  }

  Future<LoadMoreState> loadMore() async {
    return _loadData(_page + 1, false);
  }

  Future<LoadMoreState> _loadData(int page, bool reload) async {
    if (reload) {
      _state.value = StateValue.Loading;
    }

    PageData<ArticleEntity> articleData;
    try {
      if (_catId == null) {
        articleData = await repo.getNewsProjectList(page);
      } else {
        articleData = await repo.getProjectList(page, _catId);
      }
    } catch (e) {
      if (reload) {
        _state.value = StateValue.Error;
      }
      return LoadMoreState.Error;
    }

    if (page == START_PAGE) {
      _list.value = articleData.datas;
    } else {
      _list.value = []..addAll(_list.value)..addAll(articleData.datas);
    }
    _page = page;
    if (articleData.over && reload) {
      _hasMore.value = false;
    }
    if (reload) {
      _state.value = StateValue.Success;
    }
    if (articleData.over) {
      return LoadMoreState.End;
    }
    return LoadMoreState.Normal;
  }

  Future<void> refresh() async {
    await _loadData(START_PAGE, false);
  }

  void retry() {
    _loadData(START_PAGE, true);
  }
}
