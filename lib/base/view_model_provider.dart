import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/base/view_model.dart';

typedef T ViewModelBuilder<T>(BuildContext context);
typedef Widget WidgetBuilder<T>(BuildContext context, T bloc);

class ViewModelProvider<T extends ViewModel> extends StatelessWidget {
  final Widget child;
  final ViewModelBuilder viewModelBuilder;
  final Disposer<T> disposer;

  ViewModelProvider({this.child, this.viewModelBuilder, this.disposer});

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<T>(
      builder: (BuildContext context) {
        T vm = viewModelBuilder(context);
        vm.onInit();
        return vm;
      },
      dispose: (context, T vm) {
        disposer?.call(context, vm);
        vm.dispose();
      },
      child: child,
    );
  }
}
