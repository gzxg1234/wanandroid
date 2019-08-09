import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/base_bloc.dart';
import 'package:wanandroid/component/common_list.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/repo.dart';
import 'package:wanandroid/util/utils.dart';

class WxBloc extends BaseBloc {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);

  ValueListenable<StateValue> get state => _state;

  ValueNotifier<List<CategoryEntity>> _catList = ValueNotifier(null);

  ValueListenable<List<CategoryEntity>> get catList => _catList;

  @override
  void initial() {
    super.initial();
    fetchCategoryData();
  }

  Future<void> fetchCategoryData([bool init = true]) async {
    if (init) {
      _state.value = StateValue.Loading;
    }
    try {
      var cats = await ApiClient.getWOAList(cancelToken) ?? [];
      _catList.value = cats;
      if (init) {
        _state.value = StateValue.Success;
      }
    } catch (e) {
      toastMsg(Utils.getErrorMsg(e, "加载失败"));
      if (init) {
        _state.value = StateValue.Error;
      }
    }
  }

  Future<PageBean<ArticleEntity>> fetchList(int page, int id) {
    return ApiClient.getWOAArticleList(page, id, cancelToken).then((e) {
      return PageBean(e.datas, !e.over);
    });
  }
}
