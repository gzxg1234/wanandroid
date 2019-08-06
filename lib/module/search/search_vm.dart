import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/base_view_model.dart';
import 'package:wanandroid/data/app_setting.dart';

class SearchVM extends BaseViewModel {
  final ValueNotifier<String> _searchWord = ValueNotifier<String>("");
  final ValueNotifier<List<String>> _history = ValueNotifier<List<String>>([]);

  ValueListenable<List<String>> get searchHistory => _history;

  ValueListenable<String> get searchWord => _searchWord;

  @override
  void initial() {
    super.initial();
    getLocalHistory();
  }

  void getLocalHistory() async {
    _history.value = await AppSetting.getSearchHistory();
  }

  void clearHistory() {
    _history.value = [];
    AppSetting.saveSearchHistory(_history.value);
  }

  void resetWord() {
    _searchWord.value = '';
  }

  void onSearch(String word) async {
    _searchWord.value = word;
    if (word.isEmpty) {
      return;
    }
    updateHistory(word);
  }

  void updateHistory(String word) async {
    var list = await AppSetting.getSearchHistory() ?? [];
    list.removeWhere((e) => e == word);
    list.insert(0, word);
    if (list.length > 10) {
      list = list.sublist(0, 10);
    }
    _history.value = list;
    AppSetting.saveSearchHistory(list);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
