import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/util/widget_utils.dart';

import 'base_view_model.dart';

typedef T ViewModelBuilder<T>(BuildContext context);

class BaseViewModelProvider<T extends BaseViewModel> extends StatefulWidget {
  final Widget child;
  final ViewModelBuilder viewModelBuilder;
  final Disposer<T> disposer;

  BaseViewModelProvider({this.child, this.viewModelBuilder, this.disposer});

  @override
  State<StatefulWidget> createState() {
    return BaseViewModelProviderState<T>();
  }
}

class BaseViewModelProviderState<T extends BaseViewModel>
    extends State<BaseViewModelProvider<T>> {
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
