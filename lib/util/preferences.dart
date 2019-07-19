import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Preferences._internal();

  static Future<bool> set(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is int) {
      return prefs.setInt(key, value);
    } else if (value is String) {
      return prefs.setString(key, value);
    } else if (value is double) {
      return prefs.setDouble(key, value);
    } else if (value is bool) {
      return prefs.setBool(key, value);
    } else if (value is List<String>) {
      return prefs.setStringList(key, value);
    } else {
      String jsonStr = json.encode(value);
      return prefs.setString(key, jsonStr);
    }
  }

  static Future<T> get<T>(String key, T defValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) {
      return defValue;
    }
    return Future.value(prefs.get(key) as T);
  }

  static Future<T> getJson<T>(String key, Converter<T> converter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString(key);
    if (jsonStr == null) {
      return null;
    }
    return converter(json.decode(jsonStr));
  }
}

typedef T Converter<T>(Map<String, dynamic> json);
