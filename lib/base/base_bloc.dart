import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/util/utils.dart';

class BaseBloc extends ChangeNotifier {
  @protected
  final CancelToken cancelToken = CancelToken();

  // ignore: close_sinks
  final StreamController<String> _streamController =
      StreamController.broadcast();

  final List<Function> _invokeOnDispose = [];

  Stream<String> get toast => _streamController.stream;

  BaseBloc() {
    _invokeOnDispose.add(_streamController.close);
  }

  void initial() {
    dLog(this.runtimeType.toString(), "onInit");
  }

  @mustCallSuper
  void dispose() {
    dLog(this.runtimeType.toString(), "onDispose");
    cancelToken.cancel();
    _invokeOnDispose.forEach((e) => e());
    super.dispose();
  }

  void onEvent<E>(void onData(E event), [bool sticky = false]) {
    invokeOnDispose(EventBus.on<E>(sticky).listen(onData).cancel);
  }

  void toastMsg(String msg) {
    _streamController.sink.add(msg);
  }

  void invokeOnDispose(Function function) {
    _invokeOnDispose.add(function);
  }

  void log(String msg) {
    dLog(this.runtimeType.toString(), msg);
  }
}
