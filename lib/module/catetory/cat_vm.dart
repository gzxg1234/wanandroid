import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/base/base_view_model.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/event/events.dart';
import 'package:wanandroid/util/utils.dart';

class CatTabState {
  List<CategoryEntity> list;
  int index;

  CatTabState([this.list, this.index]);

  CatTabState clone() {
    return CatTabState(this.list, this.index);
  }
}

class CatVM extends BaseViewModel {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);
  ValueNotifier<CatTabState> _parentTabState = ValueNotifier(CatTabState());
  ValueNotifier<CatTabState> _childTabState = ValueNotifier(CatTabState());

  ValueListenable<StateValue> get state => _state;

  ValueListenable<CatTabState> get parentTabState => _parentTabState;

  ValueListenable<CatTabState> get childTabState => _childTabState;

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
      var list = await repo.getArticleCategoryList();
      _parentTabState.value = _parentTabState.value.clone()
        ..list = list
        ..index = 0;
      _childTabState.value = _childTabState.value.clone()
        ..index = 0
        ..list = _parentTabState.value.list[0].children;
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

  void childIndexChange(int pos) {
    _childTabState.value.index = pos;
  }

  void parentIndexChange(int pos) {
    _parentTabState.value.index = pos;
    _childTabState.value = _childTabState.value.clone()
      ..index = 0
      ..list = _parentTabState.value.list[_parentTabState.value.index].children;
  }
}
