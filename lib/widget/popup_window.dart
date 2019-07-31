import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef Widget PageBuilder<T>(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, PopupWindow<T> popupWindow);

///
/// 弹窗类，实现依附于widget显示弹窗
///
class PopupWindow<T> {
  _PopupWindowRoute<T> _route;

  final PageBuilder pageBuilder;
  final RouteTransitionsBuilder transitionsBuilder;
  final Duration transitionDuration;
  final bool barrierDismissible;

  PopupWindow(
      {this.pageBuilder,
      this.transitionsBuilder,
      this.transitionDuration,
      this.barrierDismissible = true});

  get isShown => _route != null;

  ///显示于[targetContext]元素下方
  ///[offset] 偏移量
  Future<T> showAsDropdown(
      {BuildContext targetContext, Offset offset = Offset.zero}) {
    if (_route != null) {
      if (_route.targetContext != targetContext) {
        dismiss(null);
      }
    }
    final _PopupWindowRoute<T> route = _route = _PopupWindowRoute<T>(
        targetContext: targetContext,
        offset: offset,
        pageBuilder: (context, animation, secondaryAnimation) {
          return pageBuilder(context, animation, secondaryAnimation, this);
        },
        barrierLabel:
            MaterialLocalizations.of(targetContext).modalBarrierDismissLabel,
        transitionBuilder: transitionsBuilder,
        transitionDuration: transitionDuration);
    return Navigator.of(targetContext).push(route).then((result) {
      if (route == _route) {
        _route = null;
      }
      return result;
    });
  }

  void dismiss([T result]) {
    if (_route == null) {
      return;
    }
    //pop动画结束后需要调用navigator.removeRoute移除history，不然占用的一块位置仍然无法点击
    if (_route.animation != null) {
      final route = _route;
      _route.animation.addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          route.navigator.removeRoute(route);
        }
      });
    } else {
      _route.navigator.removeRoute(_route);
    }
    _route.didPop(result ?? _route.currentResult);
    _route = null;
  }
}

class _PopupWindowRoute<T> extends PopupRoute<T> {
  _PopupWindowRoute(
      {this.targetContext,
      this.offset = Offset.zero,
      this.pageBuilder,
      this.barrierLabel,
      this.semanticLabel,
      bool barrierDismissible = true,
      Duration transitionDuration = const Duration(milliseconds: 200),
      RouteTransitionsBuilder transitionBuilder})
      : _transitionDuration = transitionDuration,
        _transitionBuilder = transitionBuilder,
        _barrierDismissible = barrierDismissible;

  bool _barrierDismissible;
  final BuildContext targetContext;
  final RoutePageBuilder pageBuilder;
  final Offset offset;
  final String semanticLabel;

  final Duration _transitionDuration;
  final RouteTransitionsBuilder _transitionBuilder;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
    );
  }

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color get barrierColor => null;

  @override
  final String barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    //获取目标widget的位置
    final RenderBox target = targetContext.findRenderObject();
    final RenderBox overlay =
        Overlay.of(targetContext).context.findRenderObject();
    final Rect overlayRect = Offset.zero & overlay.size;
    final Rect position = Rect.fromPoints(
      target.localToGlobal(target.size.topLeft(offset), ancestor: overlay),
      target.localToGlobal(target.size.bottomRight(offset), ancestor: overlay),
    );

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _PopupWindowRouteLayout(
              position,
              overlayRect,
              Directionality.of(context),
            ),
            child: pageBuilder(context, animation, secondaryAnimation),
          );
        },
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (_transitionBuilder == null) {
      return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
          child: child);
    } // Some default transition
    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }
}

class _PopupWindowRouteLayout extends SingleChildLayoutDelegate {
  _PopupWindowRouteLayout(
      this.targetPosition, this.overlayRect, this.textDirection);

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final Rect targetPosition;
  final Rect overlayRect;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    double width = constraints.biggest.width;
    double height = constraints.biggest.height;
    final invalidHeight = overlayRect.height - targetPosition.bottom;
    if (height == double.infinity) {
      height = invalidHeight;
    } else {
      height = min(invalidHeight, height);
    }
    return BoxConstraints.loose(Size(width, height));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double y = targetPosition.bottom;
    double x = targetPosition.left;
    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x + childSize.width > size.width) x = size.width - childSize.width;
    if (y + childSize.height > size.height) y = size.height - childSize.height;
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupWindowRouteLayout oldDelegate) {
    return targetPosition != oldDelegate.targetPosition;
  }
}
