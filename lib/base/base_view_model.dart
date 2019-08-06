import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/app/event_bus.dart';
import 'package:wanandroid/data/repo.dart';
import 'package:wanandroid/util/utils.dart';

class BaseViewModel extends ChangeNotifier {
  @protected
  ApiClient repo;
  final CancelToken _cancelToken = CancelToken();

  // ignore: close_sinks
  final StreamController<String> _streamController =
      StreamController.broadcast();

  final List<Function> _invokeOnDispose = [];

  Stream<String> get toast => _streamController.stream;

  BaseViewModel() {
    repo = ApiClient(_cancelToken);
    _invokeOnDispose.add(_streamController.close);
  }

  void initial() {
    dLog(this.runtimeType.toString(), "onInit");
  }

  @mustCallSuper
  void dispose() {
    dLog(this.runtimeType.toString(), "onDispose");
    _invokeOnDispose.forEach((e) => e());
    _cancelToken.cancel("dispose");
    super.dispose();
  }

  void onEvent<E>(void onData(E event)) {
    invokeOnDispose(EventBus.on<E>().listen(onData).cancel);
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
