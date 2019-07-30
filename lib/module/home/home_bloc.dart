import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/base/base_bloc.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/bean/banner_entity.dart';
import 'package:wanandroid/data/bean/page_data.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';

class HomeBloc extends BaseBloc {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);
  ValueNotifier<List<BannerEntity>> _bannerData = ValueNotifier([]);
  ValueNotifier<List<ArticleEntity>> _list = ValueNotifier([]);
  ValueNotifier<int> _bannerIndex = ValueNotifier(0);

  Timer autoTurningTimer;

  int _page = -1;

  ValueListenable<StateValue> get state => _state;

  ValueListenable<List<BannerEntity>> get bannerData => _bannerData;

  ValueListenable<List<ArticleEntity>> get list => _list;

  ValueListenable<int> get bannerIndex => _bannerIndex;

  @override
  void onInit() {
    // TODO: implement onInit
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
      if (reload) {
        _state.value = StateValue.Error;
      }
      return LoadMoreState.Error;
    }

    _page = page;
    if (page == 0) {
      _bannerIndex.value = 0;
      _bannerData.value = homeData[0] ?? [];
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
    _bannerIndex.value = value;
  }
}
