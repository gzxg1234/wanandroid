import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/base_view_model.dart';
import 'package:wanandroid/event/events.dart';

class MainVM extends BaseViewModel {
  final ValueNotifier<int> _currentTab = ValueNotifier(0);
  final ValueNotifier<List<bool>> _tabRefreshState =
      ValueNotifier(List.filled(4, false));

  ValueListenable<int> get currentTab => _currentTab;

  ValueListenable<List<bool>> get tabRefreshing => _tabRefreshState;

  @override
  void initial() {
    super.initial();
    onEvent<MainTabShowRefreshEvent>((e) {
      _tabRefreshState.value = List.from(_tabRefreshState.value)
        ..[e.index] = e.show;
    });
  }

  void setCurrentTab(int index) {
    _currentTab.value = index;
  }
}
