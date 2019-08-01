import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wanandroid/base/view_model.dart';
import 'package:wanandroid/data/repo.dart';
import 'package:wanandroid/util/utils.dart';

class BaseViewModel extends ViewModel {
  @protected
  ApiClient repo;
  final CancelToken _cancelToken = CancelToken();

  StreamController<String> _streamController = StreamController.broadcast();

  Stream<String> get toast => _streamController.stream;

  BaseViewModel() {
    repo = ApiClient(_cancelToken);
  }

  @override
  void onInit() {
    super.onInit();
    dLog(this.runtimeType.toString(), "onInit");
  }

  void toastMsg(String msg) {
    //放到微任务队列里，确保widget能全部接受到
    Future.microtask(() {
      if (!_streamController.isClosed) {
        _streamController.sink.add(msg);
      }
    });
  }

  @mustCallSuper
  void onDispose() {
    dLog(this.runtimeType.toString(), "onDispose");
    _streamController.close();
    _cancelToken.cancel("dispose");
    super.onDispose();
  }

  void log(String msg) {
    dLog(this.runtimeType.toString(), msg);
  }
}
