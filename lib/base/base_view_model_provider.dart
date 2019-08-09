import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/util/widget_utils.dart';

import 'base_bloc.dart';

typedef T ViewModelBuilder<T>(BuildContext context);

class BaseBlocProvider<T extends BaseBloc> extends StatefulWidget {
  final Widget child;
  final ViewModelBuilder viewModelBuilder;
  final Disposer<T> disposer;

  BaseBlocProvider({this.child, this.viewModelBuilder, this.disposer});

  @override
  State<StatefulWidget> createState() {
    return BaseBlocProviderState<T>();
  }
}

class BaseBlocProviderState<T extends BaseBloc>
    extends State<BaseBlocProvider<T>> {
  T _vm;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<T>(
      builder: (BuildContext context) => _vm,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModelBuilder(context);
    _vm.toast.listen((e) {
      showToast(context: context, msg: e);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _vm.initial();
    }
  }

  @override
  void dispose() {
    widget.disposer?.call(context, _vm);
    _vm.dispose();
    super.dispose();
  }
}
