import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wanandroid/config/config.dart';

class Utils {
  ///延时执行
  static Future delay(int mill) {
    return Future.delayed(Duration(milliseconds: mill));
  }

  ///定时器
  static Timer interval(
      {int interval,
      int times,
      void callback(Timer timer),
      void completed(Timer timer)}) {
    return Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (times != null && timer.tick == times) {
        timer.cancel();
        if (completed != null) {
          completed(timer);
        }
        return;
      }
      callback(timer);
    });
  }

  static String getErrorMsg(dynamic e, [String defaultMsg]) {
    assert(e != null);
    String msg;
    if (e) {
      msg = e.msg;
    } else if (e is DioError) {
      switch (e.type) {
        case DioErrorType.CONNECT_TIMEOUT:
        case DioErrorType.RECEIVE_TIMEOUT:
        case DioErrorType.SEND_TIMEOUT:
          msg = "请求超时，请检查您的网络";
          break;
        case DioErrorType.RESPONSE:
          if (e.response.statusCode / 100 == 4) {
            msg = "请求错误，请稍后再试";
          } else if (e.response.statusCode / 100 == 5) {
            msg = "服务器异常，请稍后再试";
          } else {
            msg = "请求失败，请稍后再试";
          }
          break;
        case DioErrorType.DEFAULT:
          msg = "未知错误:\n${e.error.toString()}";
          break;
        case DioErrorType.CANCEL:
          return null;
          break;
      }
    } else if (e is Error) {
      dLog("error", e.toString());
    }
    if (msg == null || msg.isEmpty) {
      msg = defaultMsg;
    }
    return msg;
  }
}

void showToast({
  @required String msg,
  Toast toastLength,
  int timeInSecForIos = 1,
  double fontSize = 16.0,
  ToastGravity gravity,
  Color backgroundColor,
  Color textColor,
}) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      timeInSecForIos: timeInSecForIos,
      fontSize: fontSize,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor);
}

void dLog(String tag, String msg) {
  if (Config.DEBUG) {
    print("[$tag]:$msg");
  }
}
