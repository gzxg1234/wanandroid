import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

abstract class Bloc extends ChangeNotifier{

  void onInit() {}

  void onDispose() {
  }
}
