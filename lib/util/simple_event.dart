import 'package:flutter/cupertino.dart';

class SimpleNotifier extends ValueNotifier<bool> {
  SimpleNotifier() : super(true);

  void notify() {
    value = !value;
  }
}
