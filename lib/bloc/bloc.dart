import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

abstract class Bloc {
  final List<ValueNotifier> _fields = [];

  void onInit() {}

  @mustCallSuper
  void onDispose() {
    _fields.forEach((i) {
      i.dispose();
    });
  }

  void closeStreamOnDispose(List<ValueNotifier> streamField) {
    streamField.removeWhere((e){
      return _fields.contains(e);
    });
    _fields.addAll(streamField);
  }
}
