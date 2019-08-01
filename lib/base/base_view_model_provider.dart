import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid/base/view_model_provider.dart';
import 'package:wanandroid/util/widget_utils.dart';

import 'base_view_model.dart';

class BaseViewModelProvider<T extends BaseViewModel>
    extends ViewModelProvider<T> {
  BaseViewModelProvider(
      {Disposer<T> disposer,
      @required ViewModelBuilder<T> viewModelBuilder,
      Widget child})
      : super(
            disposer: disposer,
            viewModelBuilder: viewModelBuilder,
            child: Builder(builder: (context) {
              return StreamBuilder(
                  stream: Provider.of<T>(context).toast,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.active) {
                      showToast(context: context, msg: snap.data);
                    }
                    return child;
                  });
            }));
}
