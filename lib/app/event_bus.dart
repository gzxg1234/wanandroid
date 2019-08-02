import 'dart:async';

class EventBus {
  // ignore: close_sinks
  static final StreamController _bus = StreamController.broadcast();

  static void send(Object event) {
    _bus.sink.add(event);
  }

  static Stream<T> on<T>() {
    return _bus.stream.where((e) => e.runtimeType == T).cast<T>();
  }
}
