import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/base_view_model.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/util/utils.dart';

class ProjectTabState {
  List<CategoryEntity> list;
  int index;

  ProjectTabState([this.list, this.index]);

  ProjectTabState clone() {
    return ProjectTabState(this.list, this.index);
  }
}

class ProjectVM extends BaseViewModel {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);

  ValueListenable<StateValue> get state => _state;

  ValueNotifier<ProjectTabState> _tabState =
      ValueNotifier(ProjectTabState([], 0));

  ValueListenable<ProjectTabState> get tabState => _tabState;

  @override
  void onInit() {
    super.onInit();
    fetchCategoryData();
  }

  Future<void> fetchCategoryData([bool init = true]) async {
    if (init) {
      _state.value = StateValue.Loading;
    }
    try {
      var cats = await repo.getProjectCategoryList() ?? []
        ..insert(0, CategoryEntity(name: "最新", id: null));
      _tabState.value = _tabState.value.clone()
        ..list = cats
        ..index = 0;
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

  void indexChange(int index) {
    _tabState.value.index = index;
  }
}
