import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef void RouteCreatedCallback(Route<dynamic> route);

Future<T> showPopupAsDropdown<T>(
    {@required BuildContext context,
    RouteCreatedCallback routeCreatedCallback,
    @required RoutePageBuilder pageBuilder,
    Offset offset = Offset.zero,
    Duration transitionDuration,
    RouteTransitionsBuilder transitionBuilder,
    String label}) {
  final RenderBox target = context.findRenderObject();
  final RenderBox overlay = Overlay.of(context).context.findRenderObject();
  final Rect overlayRect = Offset.zero & overlay.size;
  final Rect position = Rect.fromPoints(
    target.localToGlobal(target.size.topLeft(offset), ancestor: overlay),
    target.localToGlobal(target.size.bottomRight(offset), ancestor: overlay),
  );

  var route = _PopupWindowRoute<T>(
    position: position,
    overlayRect: overlayRect,
    pageBuilder: pageBuilder,
    semanticLabel: label,
    transitionBuilder: transitionBuilder,
    transitionDuration: transitionDuration,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  );
  routeCreatedCallback?.call(route);
  return Navigator.of(context, rootNavigator: true).push(route);
}

class _PopupWindowRoute<T> extends PopupRoute<T> {
  _PopupWindowRoute(
      {this.position,
      this.overlayRect,
      this.pageBuilder,
      this.barrierLabel,
      this.semanticLabel,
      Duration transitionDuration = const Duration(milliseconds: 200),
      RouteTransitionsBuilder transitionBuilder})
      : _transitionDuration = transitionDuration,
        _transitionBuilder = transitionBuilder;

  final RoutePageBuilder pageBuilder;
  final Rect position;
  final Rect overlayRect;
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
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => null;

  @override
  final String barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
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
    print(targetPosition);
    print(childSize);
    print(x);
    print(y);
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
