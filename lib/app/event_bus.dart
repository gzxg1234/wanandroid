import 'dart:async';

import 'package:rxdart/rxdart.dart';

class EventBus {
  // ignore: close_sinks
  static final PublishSubject _bus = PublishSubject();

  static final Map<Type, Object> _stickyEvents = {};

  static void post(Object event) {
    _bus.sink.add(event);
  }

  static void removeStickEvent(Type type) {
    _stickyEvents.remove(type);
  }

  static void removeAllStickEvent() {
    _stickyEvents.clear();
  }

  static void postSticky(Object event) {
    _stickyEvents[event.runtimeType] = event;
    _bus.sink.add(event);
  }

  static Observable<T> on<T>([bool sticky = false]) {
    Observable observable = _bus.stream.ofType(TypeToken<T>());
    if (sticky && _stickyEvents.containsKey(T)) {
      observable = observable.startWith(_stickyEvents[T]);
    }
    return observable.cast<T>();
  }
}
