import 'package:flutter/material.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/common_button.dart';

import '../../main.dart';

///仿知乎清除历史记录按钮
class HistoryClearButton extends StatefulWidget {
  final VoidCallback onPressed;

  const HistoryClearButton({Key key, this.onPressed}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HistoryClearButtonState();
  }
}

class HistoryClearButtonState extends State<HistoryClearButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _slideAnimation;
  Animation<Color> _bgColorAnimation;
  bool showing = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _slideAnimation = Tween<Offset>(begin: Offset(0.5, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
    _bgColorAnimation = ColorTween(
            begin: Colors.grey[100].withOpacity(0), end: Colors.grey[100])
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void close() {
    _animationController.reverse().whenComplete(() {
      showing = false;
    });
  }

  void show() {
    _animationController.forward().whenComplete(() {
      showing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: SlideTransition(
            position: _slideAnimation,
            child: AnimatedBuilder(
                animation: _bgColorAnimation,
                builder: (context, _) {
                  return CommonButton("清空全部",
                      bgColor: _bgColorAnimation.value,
                      splashColor: Colors.transparent,
                      constraints: BoxConstraints.tightFor(height: sizeW(20)),
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: sizeW(8)),
                      onPressed: () {
                    if (showing) {
                      widget.onPressed?.call();
                      close();
                    } else {
                      show();
                    }
                  },
                      textStyle: TextStyle(
                          fontSize: sizeW(13),
                          color: MyApp.getTheme(context).textColorSecondary));
                })));
  }
}
