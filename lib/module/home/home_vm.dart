import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/base/base_view_model.dart';
import 'package:wanandroid/component/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/bean/banner_entity.dart';
import 'package:wanandroid/data/bean/page_data.dart';
import 'package:wanandroid/util/utils.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';

class HomeBannerState {
  List<BannerEntity> list;
  int index;

  HomeBannerState([this.list, this.index]);

  HomeBannerState clone() {
    return HomeBannerState(this.list, this.index);
  }
}

class HomeVM extends BaseViewModel {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);
  ValueNotifier<List<ArticleEntity>> _list = ValueNotifier([]);
  ValueNotifier<HomeBannerState> _bannerState = ValueNotifier(HomeBannerState([],0));

  Timer autoTurningTimer;

  int _page = -1;

  ValueListenable<StateValue> get state => _state;

  ValueListenable<List<ArticleEntity>> get list => _list;

  ValueListenable<HomeBannerState> get bannerState => _bannerState;

  @override
  void onInit() {
    super.onInit();
    retry();
  }

  Future<LoadMoreState> loadMore() async {
    return _loadData(_page + 1, false);
  }

  Future<LoadMoreState> _loadData(int page, bool reload) async {
    if (reload) {
      _state.value = StateValue.Loading;
    }

    List homeData;
    try {
      homeData = await repo.getHomeData(page);
    } catch (e) {
      toastMsg(Utils.getErrorMsg(e,"加载失败"));
      if (reload) {
        _state.value = StateValue.Error;
      }
      return LoadMoreState.Error;
    }

    _page = page;
    if (page == 0) {
      _bannerState.value = _bannerState.value.clone()
      ..list = homeData[0] ?? []
      ..index = 0;
    }

    PageData<ArticleEntity> articleData = homeData[1];
    if (page == 0) {
      _list.value = articleData.datas;
    } else {
      _list.value = []..addAll(_list.value)..addAll(articleData.datas);
    }
    if (reload) {
      _state.value = StateValue.Success;
    }
    if (articleData.over) {
      return LoadMoreState.End;
    }
    return LoadMoreState.Normal;
  }

  void retry() {
    _loadData(0, true);
  }

  Future<void> refresh() async {
    await _loadData(0, false);
  }

  void bannerChanged(int value) {
    _bannerState.value = _bannerState.value.clone()
    ..index = value;
  }
}
