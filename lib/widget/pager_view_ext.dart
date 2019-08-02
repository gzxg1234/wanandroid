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

  final ScrollPhysics physics;

  final bool pageSnapping;

  final ValueChanged<int> onPageChanged;

  final IndexedWidgetBuilder itemBuilder;

  final int autoTurningTime;

  final DragStartBehavior dragStartBehavior;

  final ViewPagerController controller;

  ViewPager(
      {Key key,
      this.scrollDirection = Axis.horizontal,
      this.reverse = false,
      this.autoTurningTime,
      ViewPagerController controller,
      this.physics,
      this.pageSnapping = true,
      this.onPageChanged,
      @required this.itemBuilder,
      this.dragStartBehavior = DragStartBehavior.start})
      : controller = controller ?? ViewPagerController(),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    print('createState');
    return ViewPagerState();
  }
}

class ViewPagerState extends State<ViewPager> {
  Timer autoTurningTimer;

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _stopAutoScroll();
    if (widget.controller.itemCount > 1 && widget.autoTurningTime != null) {
      autoTurningTimer = Timer.periodic(
          Duration(milliseconds: widget.autoTurningTime), (timer) {
        widget.controller.nextPage(
            duration: Duration(milliseconds: 500), curve: Curves.linear);
      });
    }
  }

  void _stopAutoScroll() {
    autoTurningTimer?.cancel();
  }

  @override
  void didUpdateWidget(ViewPager oldWidget) {
    if (oldWidget.controller != widget.controller ||
        oldWidget.autoTurningTime != widget.autoTurningTime) {
      _startAutoScroll();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ValueChanged<int> onPageChanged =
        widget.controller._pageChangedWrapper(widget.onPageChanged);
    final IndexedWidgetBuilder itemBuilder =
        widget.controller._itemBuilderWrapper(widget.itemBuilder);
    final itemCount = widget.controller.realItemCount;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        ///用户滑动时停止滚动任务
        if (n is UserScrollNotification) {
          if (n.direction == ScrollDirection.idle) {
            _startAutoScroll();
          } else {
            _stopAutoScroll();
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
        controller: widget.controller,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class ViewPagerController extends PageController {
  static const int ITEM_COUNT_RATIO = 300;

  final int itemCount;

  final bool cycle;

  ViewPagerController({
    this.itemCount = 0,
    this.cycle = false,
    int initialPage = 0,
    bool keepPage = true,
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
    super.jumpToPage(page);
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

  ValueChanged<int> _pageChangedWrapper(ValueChanged<int> valueChanged) {
    if (cycle) {
      return (int index) {
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
  int get realItemCount =>
      cycle ? (itemCount * ITEM_COUNT_RATIO + 2) : itemCount;

  ///当前实际位置
  int get realCurrentPage => this.page.toInt();

  ///当前虚拟位置
  int get currentPage =>
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
