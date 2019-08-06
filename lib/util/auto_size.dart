import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

//设计稿尺寸
Size designSize;
//尺寸缩放比例
Size _sizeRatio;

void autoSize(double designWidth, double designHeight) {
  designSize = Size(designWidth, designHeight);
  _calculateRatio();
  var _originOnMetricsChanged = window.onMetricsChanged;
  window.onMetricsChanged = () {
    _originOnMetricsChanged?.call();
    _calculateRatio();
  };
}

void _calculateRatio() {
  var window = WidgetsBinding.instance.window;
  _sizeRatio = Size(
    min(window.physicalSize.height, window.physicalSize.width) /
        window.devicePixelRatio /
        designSize.width,
    max(window.physicalSize.height, window.physicalSize.width) /
        designSize.height,
  );

  print("autosize ratio ${_sizeRatio.toString()}");
}

double sizeW(double px) {
  return px * _sizeRatio.width;
}

double sizeH(double px) {
  return px * _sizeRatio.height;
}

//修改ViewConfiguration的方法会影响第三方包，比如webview中页面大小异常
//
//double getPixelRatio() {
//  return window.physicalSize.width / _designWidth;
//}
//
//void runAutoSizeApp(int designWidth, Widget app) {
//  _designWidth = designWidth;
//  AutoSizeWidgetsFlutterBinding.ensureInitialized()
//    ..attachRootWidget(app)
//    ..scheduleWarmUpFrame();
//}
//
//class AutoSizeWidgetsFlutterBinding extends WidgetsFlutterBinding {
//  static WidgetsBinding ensureInitialized() {
//    if (WidgetsBinding.instance == null) AutoSizeWidgetsFlutterBinding();
//    return WidgetsBinding.instance;
//  }
//
//  @override
//  ViewConfiguration createViewConfiguration() {
//    double devicePixelRatio = window.devicePixelRatio;
//    devicePixelRatio = getPixelRatio();
//    return ViewConfiguration(
//      size: window.physicalSize / devicePixelRatio,
//      devicePixelRatio: devicePixelRatio,
//    );
//  }
//
//  @override
//  void initInstances() {
//    super.initInstances();
//    window.onPointerDataPacket = _handlePointerDataPacket;
//  }
//
//  @override
//  void unlocked() {
//    super.unlocked();
//    _flushPointerEventQueue();
//  }
//
//  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();
//
//  void _handlePointerDataPacket(PointerDataPacket packet) {
//    // We convert pointer data to logical pixels so that e.g. the touch slop can be
//    // defined in a device-independent manner.
//    _pendingPointerEvents
//        .addAll(PointerEventConverter.expand(packet.data, getPixelRatio()));
//    if (!locked) _flushPointerEventQueue();
//  }
//
//  @override
//  void cancelPointer(int pointer) {
//    super.cancelPointer(pointer);
//    if (_pendingPointerEvents.isEmpty && !locked)
//      scheduleMicrotask(_flushPointerEventQueue);
//    _pendingPointerEvents.addFirst(PointerCancelEvent(pointer: pointer));
//  }
//
//  void _flushPointerEventQueue() {
//    assert(!locked);
//    while (_pendingPointerEvents.isNotEmpty)
//      _handlePointerEvent(_pendingPointerEvents.removeFirst());
//  }
//
//  final Map<int, HitTestResult> _hitTests = <int, HitTestResult>{};
//
//  void _handlePointerEvent(PointerEvent event) {
//    assert(!locked);
//    HitTestResult result;
//    if (event is PointerDownEvent) {
//      assert(!_hitTests.containsKey(event.pointer));
//      result = HitTestResult();
//      hitTest(result, event.position);
//      _hitTests[event.pointer] = result;
//      assert(() {
//        if (debugPrintHitTestResults) debugPrint('$event: $result');
//        return true;
//      }());
//    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
//      result = _hitTests.remove(event.pointer);
//    } else if (event.down) {
//      result = _hitTests[event.pointer];
//    } else {
//      return; // We currently ignore add, remove, and hover move events.
//    }
//    if (result != null) dispatchEvent(event, result);
//  }
//}
