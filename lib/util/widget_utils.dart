import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

///回滚顶部最大动画时间
const MAX_SCROLL_TOP_DURATION = 500;

///回滚顶部速度每毫秒
const SCROLL_TOP_VELOCITY = 3;

///滚动到顶部
void scrollToTop(ScrollController scrollController) {
  int mill = min(MAX_SCROLL_TOP_DURATION,
      (scrollController.offset / SCROLL_TOP_VELOCITY).round());
  scrollController.animateTo(0,
      duration: Duration(milliseconds: mill), curve: Curves.ease);
}

void popRoute<T>(ModalRoute<T> route, [T result]) {
  if (route.animation != null) {
    route.animation.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        route.navigator.removeRoute(route);
      }
    });
  } else {
    route.navigator.removeRoute(route);
  }
  route.didPop(result ?? route.currentResult);
}

///toast提示
void showToast({
  BuildContext context,
  @required String msg,
  Toast toastLength,
  int timeInSecForIos = 1,
  double fontSize = 16.0,
  ToastGravity gravity,
  Color backgroundColor,
  Color textColor,
}) {
  Fluttertoast.showToast(
      msg: "$msg",
      toastLength: toastLength,
      timeInSecForIos: timeInSecForIos,
      fontSize: fontSize,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor);
}
