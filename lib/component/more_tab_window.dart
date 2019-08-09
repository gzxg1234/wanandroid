import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid/main.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/common_button.dart';
import 'package:wanandroid/widget/popup_window.dart';

class MoreTabWindow extends PopupWindow<int>{
  MoreTabWindow(List<String> tabs, int checkedIndex)
      : super(
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return FadeTransition(
                opacity:
                    CurvedAnimation(parent: animation, curve: Curves.linear),
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 300),
            pageBuilder: (context, animation, _, window) {
              var animate =
                  Tween<Offset>(begin: Offset(0, -1), end: Offset.zero).animate(
                      CurvedAnimation(parent: animation, curve: Curves.linear));
              return GestureDetector(
                onTap: () {
                  window.dismiss(null);
                },
                child: Container(
                  constraints: BoxConstraints.expand(),
                  decoration: BoxDecoration(color: Colors.black54),
                  child: GestureDetector(
                    //加一层点击，不然白色包裹部分也会响应关闭弹窗
                    onTap: () {},
                    child: Stack(
                      children: <Widget>[
                        ClipRect(
                          child: SlideTransition(
                            position: animate,
                            child: Container(
                              padding: EdgeInsets.all(sizeW(16)),
                              constraints: BoxConstraints.tightFor(
                                  width: double.infinity),
                              color: MyApp.getTheme(context).backgroundColor,
                              child: SingleChildScrollView(
                                child: Wrap(
                                    runSpacing: sizeW(8),
                                    spacing: sizeW(8),
                                    children: () {
                                      return buildCatFlowChildren(
                                          context, window, tabs, checkedIndex);
                                    }()),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });

  static List<Widget> buildCatFlowChildren(BuildContext context,
      PopupWindow popupWindow, List<String> tabs, int checkedIndex) {
    List<Widget> children = [];
    for (int i = 0; i < tabs.length; i++) {
      String item = tabs[i];
      bool checked = i == checkedIndex;
      var normalTextStyle = TextStyle(
          color: MyApp.getTheme(context).textColorPrimary, fontSize: sizeW(12));

      var checkedTextStyle = TextStyle(
          color: MyApp.getTheme(context).textColorPrimaryInverse,
          fontSize: sizeW(12));

      var checkedWidgetBgColor = MyApp.getTheme(context).tagBgColorChecked;

      var unCheckedWidgetBgColor =
          MyApp.getTheme(context).tagBgColor;

      children.add(CommonButton(
        item,
        enable: !checked,
        onPressed: () {
          popupWindow.dismiss(i);
        },
        constraints: BoxConstraints.tightFor(height: sizeW(30)),
        textStyle: checked ? checkedTextStyle : normalTextStyle,
        pressedTextStyle: checkedTextStyle,
        bgColor: checked ? checkedWidgetBgColor : unCheckedWidgetBgColor,
        pressedBgColor: checkedWidgetBgColor,
        shapeBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizeW(15))),
      ));
    }
    return children;
  }
}
