import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/base_view_model.dart';
import 'package:wanandroid/data/bean/bean.dart';
import 'package:wanandroid/data/repo.dart';

class HotWordBloc extends BaseViewModel {
  ValueNotifier<List<HotWordEntity>> _hotWordList = ValueNotifier([]);

  ValueListenable<List<HotWordEntity>> get hotWordList => _hotWordList;

  void refresh() async {
    try {
      var list = await repo.getHotWord();
      _hotWordList.value = list;
    } catch (e) {
      log("refresh hot word error:\n${e.toString()}");
    }
  }
}
