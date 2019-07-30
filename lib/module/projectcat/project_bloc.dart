import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/base_bloc.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';

class ProjectBloc extends BaseBloc {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);
  ValueNotifier<List<CategoryEntity>> _catList = ValueNotifier([]);
  ValueNotifier<int> _currentCat = ValueNotifier(0);

  ValueListenable<StateValue> get state => _state;

  ValueListenable<List<CategoryEntity>> get catList => _catList;

  ValueListenable<int> get currentCat => _currentCat;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadData();
  }

  void loadData() async {
    _state.value = StateValue.Loading;
    try {
      List<CategoryEntity> cats = await repo.getProjectCategoryList() ?? []
        ..insert(0, CategoryEntity(name: "最新", id: null));
      _catList.value = cats;
      _state.value = StateValue.Success;
    } catch (e) {
      _state.value = StateValue.Error;
    }
  }
}
