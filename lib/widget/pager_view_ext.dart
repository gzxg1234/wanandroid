import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

///扩展pageview，支持无限循环
///两种实现无线循环的方法
///1方法未实现真正的循环，只是足够大
///2方法实现真正循环，但是滑到在首尾时需要调整page到中间，会出现页面闪动
///结合两种方法，实现真正循环同时减少滑到首尾的频率
class ViewPager extends StatefulWidget {
  final Axis scrollDirection;

  final bool reverse;

  final PageControllerExt controller;

  final ScrollPhysics physics;

  final bool pageSnapping;

  final ValueChanged<int> onPageChanged;

  final IndexedWidgetBuilder itemBuilder;

  final int autoTurningTime;

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
  PageControllerExt _pageControllerExt;

  @override
  void dispose() {
    stopAutoScroll();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageControllerExt =
        widget.controller ?? PageControllerExt(initialPage: 0, cycle: false);
    startAutoScroll();
  }

  void startAutoScroll() {
    stopAutoScroll();
    if (_pageControllerExt.itemCount > 1 && widget.autoTurningTime != null) {
      autoTurningTimer = Timer.periodic(
          Duration(milliseconds: widget.autoTurningTime), (timer) {
        widget.controller.nextPage(
            duration: Duration(milliseconds: 500), curve: Curves.linear);
      });
    }
  }

  void stopAutoScroll() {
    autoTurningTimer?.cancel();
  }

  @override
  void didUpdateWidget(ViewPager oldWidget) {
    print(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _pageControllerExt?.dispose();
      _pageControllerExt =
          widget.controller ?? PageControllerExt(initialPage: 0, cycle: false);
      startAutoScroll();
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ValueChanged<int> onPageChanged =
        _pageControllerExt._pageChangedWrapper(widget.onPageChanged);
    final IndexedWidgetBuilder itemBuilder =
        _pageControllerExt._itemBuilderWrapper(widget.itemBuilder);
    final itemCount = _pageControllerExt.realItemCount;

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
        controller: _pageControllerExt,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class PageControllerExt extends PageController {
  static const int ITEM_COUNT_RATIO = 300;

  final int itemCount;

  final bool cycle;

  PageControllerExt({
    this.itemCount = 0,
    this.cycle = false,
    int initialPage = 0,
    bool keepPage = false,
    double viewportFraction = 1.0,
  }) : super(
            initialPage: () {
              return cycle
                  ? itemCount * (ITEM_COUNT_RATIO ~/ 2) + 1 + initialPage
                  : initialPage;
            }(),
            keepPage: keepPage,
            viewportFraction: viewportFraction);

  @override
  Future<void> animateToPage(int page,
      {@required Duration duration, @required Curve curve}) {
    if (cycle) {
      page = realCurrentPage + page - currentPage;
    }
    return super.animateToPage(page, duration: duration, curve: curve);
  }

  @override
  Future<void> nextPage({Duration duration, Curve curve}) {
    if (cycle) {
      return animateToPage(currentPage + 1, duration: duration, curve: curve);
    }
    if (realCurrentPage == realItemCount - 1) {
      return animateToPage(0, duration: duration, curve: curve);
    }
    return super.nextPage(duration: duration, curve: curve);
  }

  @override
  void jumpToPage(int page) {
    if (cycle) {
      page = realCurrentPage + page - currentPage;
    }
    super.jumpToPage(realCurrentPage + page - currentPage);
  }

  void _superJumpToPage(int page) {
    super.jumpToPage(page);
  }

  IndexedWidgetBuilder _itemBuilderWrapper(IndexedWidgetBuilder builder) {
    if (cycle) {
      return (BuildContext context, int index) {
        return builder?.call(context, _getVirtualIndex(index));
      };
    }
    return builder;
  }

//  3 0 1 2 3 0 1 2 3 0 1 2 3 0
  ValueChanged<int> _pageChangedWrapper(ValueChanged<int> valueChanged) {
    if (cycle) {
      return (int index) {
        print(index);
        if (itemCount > 0) {
          valueChanged?.call(_getVirtualIndex(index));
          if (_isCycleHead(index)) {
            _superJumpToPage(_centerIndex(itemCount - 1));
          } else if (_isCycleTail(index)) {
            _superJumpToPage(_centerIndex(0));
          }
        }
      };
    }
    return valueChanged;
  }

  ///中心位置
  int _centerIndex(int index) {
    return itemCount * (ITEM_COUNT_RATIO ~/ 2) + 1 + index;
  }

  ///实际位置转虚拟位置
  int _getVirtualIndex(int realIndex) {
    if (!cycle) {
      return realIndex;
    }
    if (_isCycleHead(realIndex)) return itemCount - 1;
    if (_isCycleTail(realIndex)) return 0;
    return (realIndex - 1) % itemCount;
  }

  ///是否是无限循环头部
  bool _isCycleHead(int index) => index == 0;

  ///是否是无限循环尾部
  bool _isCycleTail(int index) => index == itemCount * ITEM_COUNT_RATIO + 1;

  ///当前实际长度
  get realItemCount => cycle ? (itemCount * ITEM_COUNT_RATIO + 2) : itemCount;

  ///当前实际位置
  get realCurrentPage => this.page.toInt();

  ///当前虚拟位置
  get currentPage =>
      cycle ? (realCurrentPage % itemCount - 1) : realCurrentPage;
}
//
//class CyclePageControllerExt extends PageController {
//  final bool cycle;
//  final int itemCount;
//
//  PageControllerExt({
//    this.cycle = false,
//    this.itemCount = 0,
//    int initialPage = 0,
//    bool keepPage = false,
//    double viewportFraction = 1.0,
//  }) : super(
//            initialPage: () {
//              print(
//                  "${initialPage.toString()}，${itemCount * ITEM_COUNT_RATIO ~/ 2}");
//              return cycle
//                  ? itemCount * ITEM_COUNT_RATIO ~/ 2 + initialPage
//                  : initialPage;
//            }(),
//            keepPage: keepPage,
//            viewportFraction: viewportFraction);
//
//  @override
//  Future<void> animateToPage(int page,
//      {@required Duration duration, @required Curve curve}) {
//    int curPage = pageInt % itemCount;
//    return super.animateToPage(pageInt + page - curPage,
//        duration: duration, curve: curve);
//  }
//
//
//  @override
//  void jumpToPage(int page) {
//    int curPage = pageInt % itemCount;
//    super.jumpToPage(pageInt + page - curPage);
//  }
//
//  void _superJumpToPage(int page) {
//    super.jumpToPage(page);
//  }
//
//  get realPageInt => this.page.toInt() % itemCount;
//
//  get pageInt => this.page.toInt();
//}
