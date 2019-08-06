import 'package:wanandroid/util/preferences.dart';

class AppSetting {

  static Future<bool> saveSearchHistory(List<String> list) async {
    return Preferences.set("serachHistory", list);
  }

  static Future<List<String>> getSearchHistory() async {
    return Preferences.get<List<String>>("serachHistory",[]);
  }
}
