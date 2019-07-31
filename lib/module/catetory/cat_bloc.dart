import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/base_bloc.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/util/utils.dart';

class CatBloc extends BaseBloc {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);
  ValueNotifier<List<CategoryEntity>> _catList = ValueNotifier([]);
  ValueNotifier<List<CategoryEntity>> _subCatList = ValueNotifier([]);
  ValueNotifier<int> _currentCatIndex = ValueNotifier(0);
  ValueNotifier<int> _currentSubCatIndex = ValueNotifier(0);

  ValueListenable<StateValue> get state => _state;

  ValueListenable<List<CategoryEntity>> get catList => _catList;

  ValueListenable<List<CategoryEntity>> get subCatList => _subCatList;

  ValueListenable<int> get currentCatIndex => _currentCatIndex;

  ValueListenable<int> get currentSubCatIndex => _currentSubCatIndex;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchCategoryData();
  }

  Future<void> fetchCategoryData([bool init = true]) async {
    if (init) {
      _state.value = StateValue.Loading;
    }
    try {
      _catList.value = await repo.getArticleCategoryList();
      setParentCatPosition(0);
      if (init) {
        _state.value = StateValue.Success;
      }
    } catch (e) {
      Utils.toastError(e, "加载失败");
      if (init) {
        _state.value = StateValue.Error;
      }
    }
  }

  void setSubCatPosition(int pos) {
    _currentSubCatIndex.value = pos;
  }

  void setParentCatPosition(int pos) {
    _currentCatIndex.value = pos;
    _currentSubCatIndex.value = 0;
    _subCatList.value = _catList.value[pos].children;
  }
}
