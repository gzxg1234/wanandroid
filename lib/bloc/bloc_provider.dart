import 'package:flutter/material.dart';

import 'bloc.dart';

typedef T BlocBuilder<T>(BuildContext context);
typedef Widget WidgetBuilder<T>(BuildContext context, T bloc);

class BlocProvider<T extends Bloc> extends StatefulWidget {
  final Widget child;
  final BlocBuilder blocBuilder;
  final VoidCallback onDispose;

  const BlocProvider(
      {Key key,
      @required this.child,
      @required this.blocBuilder,
      this.onDispose})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State<T>();
  }

  static _type<T>() {
    return T;
  }

  static T of<T extends Bloc>(BuildContext context) {
    _InheritedWidget<T> widget =
        context.inheritFromWidgetOfExactType(_type<_InheritedWidget<T>>());
    return widget?.bloc;
  }
}

class _State<T extends Bloc> extends State<BlocProvider<T>> {
  T bloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc = widget.blocBuilder(context);
    bloc.onInit();
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    bloc.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _InheritedWidget<T>(
      bloc: bloc,
      child: widget.child,
    );
  }
}

class BlocConsumer<T extends Bloc> extends StatelessWidget {
  final WidgetBuilder<T> builder;

  const BlocConsumer({Key key, @required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return builder(context, BlocProvider.of<T>(context));
  }
}

class _InheritedWidget<T extends Bloc> extends InheritedWidget {
  final T bloc;

  _InheritedWidget({this.bloc, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedWidget<T> oldWidget) {
    print("updateShouldNotify");
    return oldWidget.bloc != bloc;
  }
}
