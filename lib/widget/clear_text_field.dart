import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../r.dart';

///包含清除按钮的输入框
class ClearableTextField extends StatefulWidget {
  final TextField child;
  final Size clearIconSize;

  ClearableTextField({this.child, this.clearIconSize});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<ClearableTextField> {
  @override
  Widget build(BuildContext context) {
    widget.child.controller?.addListener(() {
      setState(() {});
    });
    return Row(
      children: <Widget>[
        Expanded(child: widget.child),
        Offstage(
          child: SizedBox(
            width: widget.clearIconSize.width,
            height: widget.clearIconSize.height,
            child: GestureDetector(
              onTap: () {
                widget.child.controller.clear();
              },
              child: Image.asset(
                R.assetsImgIcClear,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          offstage: () {
            return widget.child.controller.value.text.isEmpty;
          }(),
        )
      ],
    );
  }
}
