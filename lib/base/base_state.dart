import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid/app/event_bus.dart';

mixin BaseStateMixin<T extends StatefulWidget> on State<T> {
  final List<Function> _invokeOnDispose = [];
  bool _afterInitStateInvoked = false;
  @protected
  final CancelToken cancelToken = CancelToken();

  void afterInitState() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_afterInitStateInvoked) {
      _afterInitStateInvoked = true;
      afterInitState();
    }
  }

  @override
  void dispose() {
    cancelToken.cancel();
    _invokeOnDispose.forEach((e) => e());
    super.dispose();
  }

  void onEvent<E>(void onData(E event)) {
    invokeOnDispose(EventBus.on<E>().listen(onData).cancel);
  }

  void invokeOnDispose(Function function) {
    _invokeOnDispose.add(function);
  }
}
