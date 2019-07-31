import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wanandroid/bloc/bloc_provider.dart';

import 'base_bloc.dart';

class BaseBlocProvider<T extends BaseBloc> extends BlocProvider<T> {
  BaseBlocProvider(
      {VoidCallback onDispose,
      @required BlocBuilder<T> blocBuilder,
      Widget child})
      : super(
            onDispose: onDispose,
            blocBuilder: blocBuilderWrap<T>(blocBuilder),
            child: child);

  static BlocBuilder<T> blocBuilderWrap<T extends BaseBloc>(
      BlocBuilder<T> builder) {
    return builder == null
        ? builder
        : (context) {
            T bloc = builder(context);
            bloc.showLoadingStream.addListener(() {
//              showLoadingDialog(context);
            });
            bloc.hideLoadingStream.addListener(() {
            });
            return bloc;
          };
  }
}
