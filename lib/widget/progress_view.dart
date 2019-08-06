import 'package:flutter/cupertino.dart';

typedef Animation<double> AnimationBuilder(Animation<double> parentAnimation);

///旋转控件
class ProgressView extends StatefulWidget {
  final Widget child;
  final Duration duration;

  ProgressView(
      {Key key, this.child, this.duration = const Duration(milliseconds: 1000)})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProgressViewState();
  }
}

class ProgressViewState extends State<ProgressView>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(
        parent: Tween<double>(begin: 0, end: 1).animate(_animationController),
        curve: Curves.linear);
    _animationController.repeat();
  }

  @override
  void didUpdateWidget(ProgressView oldWidget) {
    if (oldWidget.duration != widget.duration) {
      _animationController.duration = widget.duration;
      _animationController.reset();
      _animationController.repeat();
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
    return RotationTransition(
      child: widget.child,
      turns: _animation,
    );
  }
}
