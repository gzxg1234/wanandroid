import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid/util/size_adapter.dart';

import '../r.dart';

enum StateValue {
  Loading,
  Success,
  Error,
}

class MultiStateWidget extends StatelessWidget {
  final Widget successChild;
  final StateValue state;
  final VoidCallback onPressedRetry;

  MultiStateWidget({this.successChild, this.state, this.onPressedRetry});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IndexedStack(
      index:
          state == StateValue.Loading ? 0 : (state == StateValue.Error ? 1 : 2),
      children: <Widget>[
        _Loading(),
        _Error(onPressedRetry: onPressedRetry),
        successChild
      ],
    );
  }
}

class _Loading extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoadingState();
  }
}

class _LoadingState extends State<_Loading>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _animation = Tween(begin: 0.0, end: 2 * pi).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          Transform.rotate(
              angle: _animation.value.toDouble(),
              child: Image.asset(R.assetsImgIcLoading,
                  color: Theme.of(context).primaryColor,
                  width: $size(40),
                  height: $size(40),
                  fit: BoxFit.fitWidth)),
          Container(
            margin: EdgeInsets.only(top: $size(16)),
            child: Text(
              "努力加载中...",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: $size(14)),
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
        print("sadad");
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
              color: Color(0xff333333),
              width: $size(80),
              height: $size(80),
            ),
            Container(
              margin: EdgeInsets.only(top: $size(16)),
              child: Text(
                "加载失败~\n点击重新加载",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xff333333), fontSize: $size(14)),
              ),
            )
          ],
        ),
      ),
    );
  }
}