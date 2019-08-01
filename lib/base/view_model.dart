import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

abstract class ViewModel extends ChangeNotifier {
  void onInit() {
  }

  @mustCallSuper
  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  void onDispose() {}
}
