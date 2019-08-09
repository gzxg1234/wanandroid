import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/base/base_bloc.dart';
import 'package:wanandroid/component/common_list.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_cat_entity.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/repo.dart';
import 'package:wanandroid/event/events.dart';
import 'package:wanandroid/util/utils.dart';

class CatBloc extends BaseBloc {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);
  ValueNotifier<List<CategoryEntity>> _parentTabList = ValueNotifier(null);
  ValueNotifier<int> _parentTabIndex = ValueNotifier(0);

  ValueNotifier<List<CategoryEntity>> _childTabList = ValueNotifier(null);
  ValueNotifier<int> _childTabIndex = ValueNotifier(0);

  ValueListenable<StateValue> get state => _state;

  ValueListenable<int> get childTabIndex => _childTabIndex;

  ValueListenable<List<CategoryEntity>> get childTabList => _childTabList;

  ValueListenable<int> get parentTabIndex => _parentTabIndex;

  ValueListenable<List<CategoryEntity>> get parentTabList => _parentTabList;

  ///数据未加载前收到的跳转事件，在加载数据后处理
  JumpCategoryEvent _pendingEvent;

  @override
  void initial() {
    super.initial();
    fetchCategoryData();
    onEvent<JumpCategoryEvent>((event) {
      EventBus.removeStickEvent(event.runtimeType);
      if (_parentTabList.value != null) {
        _handleEvent(event);
      } else {
        _pendingEvent = event;
      }
    }, true);
  }

  void _handleEvent(JumpCategoryEvent event) {
    for (int i = 0; i < _parentTabList.value.length; i++) {
      List<CategoryEntity> children = _parentTabList.value[i].children;
      for (int m = 0; m < children.length; m++) {
        if (children[m].id == event.childCatId) {
          _parentTabIndex.value = i;
          _childTabList.value = _parentTabList.value[i].children;
          _childTabIndex.value = m;
          break;
        }
      }
    }
  }

  Future<void> fetchCategoryData([bool init = true]) async {
    if (init) {
      _state.value = StateValue.Loading;
    }
    try {
      var list = await ApiClient.getArticleCategoryList(cancelToken);
      _parentTabList.value = list;
      _parentTabIndex.value = 0;
      _childTabList.value = _parentTabList.value[0].children;
      _childTabIndex.value = 0;
      if (init) {
        _state.value = StateValue.Success;
      }
      if (_pendingEvent != null) {
        _handleEvent(_pendingEvent);
        _pendingEvent = null;
      }
    } catch (e) {
      toastMsg(Utils.getErrorMsg(e, "加载失败"));
      if (init) {
        _state.value = StateValue.Error;
      }
    }
  }

  Future<PageBean<ArticleEntity>> fetchList(int page, int id) {
    return ApiClient.getArticleList(page, id).then((e) {
      return PageBean(e.datas, !e.over);
    });
  }

  void childIndexChange(int pos) {
    _childTabIndex.value = 0;
  }

  void parentIndexChange(int pos) {
    _parentTabIndex.value = pos;
    _childTabList.value = _parentTabList.value[pos].children;
    _childTabIndex.value = 0;
  }
}
