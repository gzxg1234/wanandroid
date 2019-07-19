import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wanandroid/bloc/bloc.dart';
import 'package:wanandroid/util/simple_event.dart';
import 'package:wanandroid/util/utils.dart';

class BaseBloc extends Bloc {
  @protected
  final CancelToken cancelToken = CancelToken();
  final SimpleNotifier _showLoading = SimpleNotifier();
  final SimpleNotifier _hideLoading = SimpleNotifier();

  SimpleNotifier get showLoadingStream => _showLoading;

  SimpleNotifier get hideLoadingStream => _hideLoading;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    dLog(this.runtimeType.toString(), "onInit");
  }

  @mustCallSuper
  void onDispose() {
    dLog(this.runtimeType.toString(), "onDispose");
    showLoadingStream.dispose();
    hideLoadingStream.dispose();
    cancelToken.cancel("dispose");
    super.onDispose();
  }

  void showLoading() {
    _showLoading.notify();
  }

  void dismissLoading() {
    _hideLoading.notify();
  }

  void log(String msg) {
    dLog(this.runtimeType.toString(), msg);
  }
}
