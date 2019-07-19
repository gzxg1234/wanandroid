import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatefulWidget {
  final BoxConstraints constraints;
  final String text;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final TextStyle pressedTextStyle;
  final TextStyle disableTextStyle;
  final VoidCallback onPressed;
  final Color splashColor;
  final bool enable;
  final Color bgColor;
  final Color pressedBgColor;
  final Color disableBgColor;
  final ShapeBorder shapeBorder;
  final ShapeBorder pressedShapeBorder;
  final ShapeBorder disableShapeBorder;
  final bool raise;

  final EdgeInsetsGeometry margin;

  CommonButton(this.text,
      {this.constraints,
      this.margin,
      this.padding,
      this.raise = false,
      this.textStyle,
      this.pressedTextStyle,
      this.disableTextStyle,
      this.onPressed,
      this.splashColor,
      this.enable = true,
      this.bgColor,
      this.pressedBgColor,
      this.disableBgColor,
      this.shapeBorder,
      this.pressedShapeBorder,
      this.disableShapeBorder});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<CommonButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = widget.textStyle;
    if (!widget.enable && widget.disableTextStyle != null) {
      textStyle = widget.disableTextStyle;
    } else if (_pressed && widget.pressedTextStyle != null) {
      textStyle = widget.pressedTextStyle;
    }

    ShapeBorder border = widget.shapeBorder;
    if (!widget.enable && widget.disableShapeBorder != null) {
      border = widget.disableShapeBorder;
    } else if (_pressed && widget.pressedShapeBorder != null) {
      border = widget.pressedShapeBorder;
    }

    return Container(
        constraints: widget.constraints,
        margin: widget.margin,
        child: ButtonTheme.fromButtonThemeData(
            data: ButtonTheme.of(context).copyWith(minWidth: 0, height: 0),
            child: () {
              if (!widget.raise) {
                return FlatButton(
                    highlightColor: widget.pressedBgColor ??
                        widget.bgColor ??
                        Colors.transparent,
                    color: widget.bgColor,
                    disabledColor: widget.disableBgColor ?? widget.bgColor,
                    shape: border,
                    onHighlightChanged: (b) {
                      setState(() {
                        _pressed = b;
                      });
                    },
                    padding: widget.padding,
                    onPressed: widget.enable ? _handleOnPressed : null,
                    splashColor: widget.splashColor,
                    child: Text(widget.text, style: textStyle));
              } else {
                return RaisedButton(
                    highlightColor: widget.pressedBgColor ??
                        widget.bgColor ??
                        Colors.transparent,
                    color: widget.bgColor,
                    disabledColor: widget.disableBgColor ?? widget.bgColor,
                    shape: border,
                    onHighlightChanged: (b) {
                      setState(() {
                        _pressed = b;
                      });
                    },
                    padding: widget.padding,
                    onPressed: widget.enable ? _handleOnPressed : null,
                    splashColor: widget.splashColor,
                    child: Text(widget.text, style: textStyle));
              }
            }()));
  }

  void _handleOnPressed() {
    if (widget.onPressed != null) {
      widget.onPressed();
    }
  }
}
