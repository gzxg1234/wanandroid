import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/base/base_bloc.dart';
import 'package:wanandroid/base_widget/multi_state_widget.dart';
import 'package:wanandroid/data/bean/article_entity.dart';
import 'package:wanandroid/data/bean/banner_entity.dart';
import 'package:wanandroid/data/bean/page_data.dart';
import 'package:wanandroid/data/repo.dart';
import 'package:wanandroid/widget/load_more_list_view.dart';

class HomeBloc extends BaseBloc {
  ValueNotifier<StateValue> _state = ValueNotifier(StateValue.Loading);
  ValueNotifier<List<BannerEntity>> _bannerData = ValueNotifier([]);
  ValueNotifier<List<ArticleEntity>> _list = ValueNotifier([]);
  ValueNotifier<int> _currentBanner = ValueNotifier(0);

  Timer autoTurningTimer;

  int _page = -1;

  ValueListenable<StateValue> get state => _state;

  ValueListenable<List<BannerEntity>> get bannerData => _bannerData;

  ValueListenable<List<ArticleEntity>> get list => _list;

  ValueListenable<int> get currentBanner => _currentBanner;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadData(0, true);
  }

  Future<LoadMoreState> loadMore() async {
    return loadData(_page + 1, false);
  }

  Future<LoadMoreState> loadData(int page, bool reload) async {
    if (reload) {
      _state.value = StateValue.Loading;
    }

    List homeData;
    try {
      homeData = await Repo.getHomeData(page);
    } catch (e) {
      if (reload) {
        _state.value = StateValue.Error;
      }
      return LoadMoreState.Error;
    }

    _page = page;
    if (page == 0) {
      _currentBanner.value = 0;
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
    return LoadMoreState.Completed;
  }

  void retry() {
    loadData(0, true);
  }

  void bannerChanged(int value) {
    _currentBanner.value = value;
  }

  Future<void> refresh() async {
    await loadData(0, false);
  }
}
