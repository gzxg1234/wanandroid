import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const int ITEM_COUNT_RATIO = 300;

class ViewPager extends StatefulWidget {
  final Axis scrollDirection;

  final bool reverse;

  final PageControllerExt controller;

  final ScrollPhysics physics;

  final bool pageSnapping;

  final ValueChanged<int> onPageChanged;

  final IndexedWidgetBuilder itemBuilder;

  final bool cycle;

  final int autoTurningTime;

  final int itemCount;
  final DragStartBehavior dragStartBehavior;

  ViewPager(
      {Key key,
      this.scrollDirection = Axis.horizontal,
      this.reverse = false,
      this.autoTurningTime,
      this.controller,
      this.physics,
      this.pageSnapping = true,
      this.onPageChanged,
      @required this.itemBuilder,
      this.cycle = false,
      this.itemCount,
      this.dragStartBehavior = DragStartBehavior.start})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<ViewPager> {
  Timer autoTurningTimer;

  @override
  void dispose() {
    stopAutoScroll();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startAutoScroll();
  }

  void startAutoScroll() {
    stopAutoScroll();
    if (widget.itemCount > 1 && widget.autoTurningTime != null && false) {
      autoTurningTimer = Timer.periodic(
          Duration(milliseconds: widget.autoTurningTime), (timer) {
        widget.controller.animateToPage(widget.controller.realPageInt + 1,
            duration: Duration(milliseconds: 500), curve: Curves.linear);
      });
    }
  }

  void stopAutoScroll() {
    autoTurningTimer?.cancel();
  }

  static int _expandItemCount(int itemCount) {
    return itemCount * ITEM_COUNT_RATIO;
  }

  static ValueChanged<int> _onPageChangedWrapper(ValueChanged<int> valueChanged,
      int itemCount, bool cycle, PageControllerExt controllerExt) {
    if (cycle) {
      return (int index) {
        if (itemCount > 0) {
          valueChanged(index % itemCount);
          if (index == 0) {
            controllerExt?._superJumpToPage(itemCount * ITEM_COUNT_RATIO ~/ 2);
          } else if (index == itemCount * ITEM_COUNT_RATIO - 1) {
            controllerExt?._superJumpToPage(
                itemCount * ITEM_COUNT_RATIO ~/ 2 + itemCount - 1);
          }
        }
      };
    }
    return valueChanged;
  }

  static IndexedWidgetBuilder _itemBuilderWrapper(
      IndexedWidgetBuilder builder, int itemCount, bool cycle) {
    if (cycle) {
      return (BuildContext context, int index) {
        return builder?.call(context, index % itemCount);
      };
    }
    return builder;
  }

  @override
  void didUpdateWidget(ViewPager oldWidget) {
    startAutoScroll();
    oldWidget.controller.dispose();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final PageControllerExt controller = widget.controller ??
        PageControllerExt(
            initialPage: 0, cycle: true, itemCount: widget.itemCount);
    final ValueChanged<int> onPageChanged = _onPageChangedWrapper(
        widget.onPageChanged, widget.itemCount, widget.cycle, controller);
    final IndexedWidgetBuilder itemBuilder =
        _itemBuilderWrapper(widget.itemBuilder, widget.itemCount, widget.cycle);
    final itemCount = _expandItemCount(widget.itemCount);

    print("${controller.toString()},${controller.initialPage}");
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is UserScrollNotification) {
          if (n.direction == ScrollDirection.idle) {
            startAutoScroll();
          } else {
            stopAutoScroll();
          }
        }
        return false;
      },
      child: PageView.builder(
        dragStartBehavior: widget.dragStartBehavior,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        itemCount: itemCount,
        pageSnapping: widget.pageSnapping,
        onPageChanged: onPageChanged,
        controller: controller,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class PageControllerExt extends PageController {
  final bool cycle;
  final int itemCount;

  PageControllerExt({
    this.cycle = false,
    this.itemCount = 0,
    int initialPage = 0,
    bool keepPage = false,
    double viewportFraction = 1.0,
  }) : super(
            initialPage: () {
              print("${initialPage.toString()}，${itemCount * ITEM_COUNT_RATIO ~/ 2}");
              return cycle
                  ? itemCount * ITEM_COUNT_RATIO ~/ 2 + initialPage
                  : initialPage;
            }(),
            keepPage: keepPage,
            viewportFraction: viewportFraction);

  @override
  Future<void> animateToPage(int page,
      {@required Duration duration, @required Curve curve}) {
    int curPage = pageInt % itemCount;
    return super.animateToPage(pageInt + page - curPage,
        duration: duration, curve: curve);
  }

  @override
  void jumpToPage(int page) {
    int curPage = pageInt % itemCount;
    super.jumpToPage(pageInt + page - curPage);
  }

  void _superJumpToPage(int page) {
    super.jumpToPage(page);
  }

  get realPageInt => this.page.toInt() % itemCount;

  get pageInt => this.page.toInt();
}
