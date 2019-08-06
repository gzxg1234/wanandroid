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

  static Type _type<T>() {
    return T;
  }

  static Future<T> get<T>(String key, T defValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) {
      return defValue;
    }
    if (T == _type<List<String>>()) {
      return Future.value(prefs.getStringList(key) as T);
    }
    return Future.value(prefs.get(key) as T);
  }

  static Future<T> getJson<T>(String key, [Converter<T> converter]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString(key);
    if (jsonStr == null) {
      return null;
    }
    dynamic jsonData = json.decode(jsonStr);
    return converter != null ? converter(jsonData) : jsonData;
  }
}

typedef T Converter<T>(dynamic json);
