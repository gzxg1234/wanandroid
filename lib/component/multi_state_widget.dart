import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/progress_view.dart';

import '../main.dart';
import '../r.dart';

enum StateValue {
  Loading,
  Success,
  Error,
}

class MultiStateWidget extends StatelessWidget {
  final WidgetBuilder successBuilder;
  final StateValue state;
  final VoidCallback onPressedRetry;

  MultiStateWidget({this.successBuilder, this.state, this.onPressedRetry});

  @override
  Widget build(BuildContext context) {
    if (state == StateValue.Loading) {
      return _Loading();
    }
    if (state == StateValue.Error) {
      return _Error(onPressedRetry: onPressedRetry);
    }
    return successBuilder(context);
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      constraints: BoxConstraints.expand(),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ProgressView(
            duration: Duration(milliseconds: 800),
            child: Image.asset(R.assetsImgIcLoading,
                color: Theme.of(context).primaryColor,
                width: sizeW(40),
                height: sizeW(40),
                fit: BoxFit.fitWidth),
          ),
          Container(
            margin: EdgeInsets.only(top: sizeW(16)),
            child: Text(
              "努力加载中...",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: sizeW(14)),
            ),
          )
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final VoidCallback onPressedRetry;

  const _Error({Key key, this.onPressedRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressedRetry?.call();
      },
      child: Container(
        color: Colors.transparent,
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              R.assetsImgIcFailed,
              color: MyApp.getTheme(context).textColorSecondary,
              width: sizeW(80),
              fit: BoxFit.fitWidth,
            ),
            Container(
              margin: EdgeInsets.only(top: sizeW(16)),
              child: Text(
                "加载失败~\n点击重新加载",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: MyApp.getTheme(context).textColorSecondary,
                    fontSize: sizeW(14)),
              ),
            ),
            //整体往上移动一丢丢
            SizedBox(height: sizeW(50))
          ],
        ),
      ),
    );
  }
}
