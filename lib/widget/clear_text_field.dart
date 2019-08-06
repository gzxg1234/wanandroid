import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///包含清除按钮的输入框
class ClearableTextField extends StatefulWidget {
  final TextField child;
  final Widget clearIcon;

  ClearableTextField({this.child, this.clearIcon})
      : assert(child.focusNode != null),
        assert(child.controller != null);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<ClearableTextField> {
  @override
  void initState() {
    super.initState();
    widget.child.controller?.addListener(_setState);
    widget.child.focusNode?.addListener(_setState);
  }

  @override
  void didUpdateWidget(ClearableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child.controller != widget.child.controller) {
      oldWidget.child.controller?.removeListener(_setState);
      widget.child.controller?.addListener(_setState);
    }
    if (oldWidget.child.focusNode != widget.child.focusNode) {
      oldWidget.child.focusNode?.removeListener(_setState);
      widget.child.focusNode?.addListener(_setState);
    }
  }

  @override
  void dispose() {
    widget.child.focusNode?.removeListener(_setState);
    widget.child.controller?.removeListener(_setState);
    super.dispose();
  }

  void _setState() {
    setState(() {});
  }

  bool get needShowClear {
    return (widget.child.controller?.text?.isNotEmpty ?? false) &&
        (widget.child.focusNode?.hasFocus ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: widget.child),
        Offstage(
          child: GestureDetector(
            onTap: () {
              widget.child.controller.clear();
            },
            child: widget.clearIcon,
          ),
          offstage: () {
            return !needShowClear;
          }(),
        )
      ],
    );
  }
}
