import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/base_bloc.dart';

class MainBloc extends BaseBloc {

  ValueNotifier<int> _currentTab = ValueNotifier(0);

  ValueListenable<int> get currentTab => _currentTab;

  void setCurrentTab(int index) {
    _currentTab.value = index;
  }
}
