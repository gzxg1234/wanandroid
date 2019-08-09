import 'package:flutter/cupertino.dart';

typedef Animation<double> AnimationBuilder(Animation<double> parentAnimation);

///旋转控件
class RotationView extends StatefulWidget {
  final Widget child;
  final double fromDegree;
  final double toDegree;
  final Duration duration;
  final AnimationBuilder animationBuilder;

  RotationView(
      {Key key,
      this.child,
      this.fromDegree = 0,
      this.toDegree = 0,
      this.duration = const Duration(milliseconds: 300),
      this.animationBuilder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RotationViewState();
  }
}

class RotationViewState extends State<RotationView>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(RotationView oldWidget) {
    if (oldWidget.fromDegree != widget.fromDegree ||
        oldWidget.toDegree != widget.toDegree) {
      _animationController.stop();
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void forward() {
    _animationController.forward();
  }

  void reverse() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> animation =
        Tween(begin: -widget.fromDegree / 360, end: -widget.toDegree / 360)
            .animate(_animationController);
    if (widget.animationBuilder != null) {
      animation = widget.animationBuilder(animation);
    }
    return RotationTransition(
      child: widget.child,
      turns: animation,
    );
  }
}
