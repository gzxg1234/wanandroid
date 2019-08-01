import 'package:flutter/cupertino.dart';

class Event<T> extends ValueNotifier<T> {
  Event() : super(null);

  @override
  set value(T newValue) {
    if (newValue == value) {
      notifyListeners();
      return;
    }
    super.value = newValue;
  }
}
