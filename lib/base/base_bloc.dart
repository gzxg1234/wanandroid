import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:wanandroid/bloc/bloc.dart';
import 'package:wanandroid/data/repo.dart';
import 'package:wanandroid/util/simple_event.dart';
import 'package:wanandroid/util/utils.dart';

class BaseBloc extends Bloc {
  @protected
  Repo repo;
  final CancelToken _cancelToken = CancelToken();
  final SimpleNotifier _showLoading = SimpleNotifier();
  final SimpleNotifier _hideLoading = SimpleNotifier();

  SimpleNotifier get showLoadingStream => _showLoading;

  SimpleNotifier get hideLoadingStream => _hideLoading;

  BaseBloc() {
    repo = Repo(_cancelToken);
  }

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
    _cancelToken.cancel("dispose");
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
