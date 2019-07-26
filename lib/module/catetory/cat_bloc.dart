import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/base_bloc.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/data/repo.dart';

class CatBloc extends BaseBloc {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);
  ValueNotifier<List<ArticleCatEntity>> _catList = ValueNotifier([]);
  ValueNotifier<List<ArticleCatEntity>> _subCatList = ValueNotifier([]);
  ValueNotifier<int> _currentSubCat = ValueNotifier(0);

  ValueListenable<StateValue> get state => _state;

  ValueListenable<List<ArticleCatEntity>> get catList => _catList;

  ValueListenable<List<ArticleCatEntity>> get subCatList => _subCatList;

  ValueListenable<int> get currentSubCat => _currentSubCat;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadData();
  }

  void loadData() async {
    _state.value = StateValue.Loading;
    try {
      _catList.value = await Repo.getArticleCategoryList();
      setParentCatPosition(0);
      _state.value = StateValue.Success;
    } catch (e) {
      _state.value = StateValue.Error;
    }
  }

  void setParentCatPosition(int pos) {
    _subCatList.value = _catList.value[pos].children;
    _currentSubCat.value = 0;
  }
}
