import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class PageViewExt extends PageView {
  PageViewExt.builder({
    Key key,
    Axis scrollDirection = Axis.horizontal,
    bool reverse = false,
    PageControllerExt controller,
    ScrollPhysics physics,
    bool pageSnapping = true,
    ValueChanged<int> onPageChanged,
    @required IndexedWidgetBuilder itemBuilder,
    bool cycle = false,
    int itemCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) : super.builder(
            key: key,
            scrollDirection: scrollDirection,
            reverse: reverse,
            controller: controller ??
                PageControllerExt(initialPage: 0, itemCount: itemCount),
            physics: physics,
            pageSnapping: pageSnapping,
            onPageChanged: _onPageChangedWrapper(
                onPageChanged, itemCount, cycle, controller),
            itemBuilder: _itemBuilderWrapper(itemBuilder, itemCount, cycle),
            itemCount: cycle ? itemCount * ITEM_COUNT_RATIO : itemCount,
            dragStartBehavior: dragStartBehavior);
}

const int ITEM_COUNT_RATIO = 100;

class PageControllerExt extends PageController {
  bool cycle = false;
  int itemCount = 0;

  @override
  Future<Function> animateToPage(int page,
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

  get pageInt => this.page.toInt();

  PageControllerExt({
    int initialPage = 0,
    this.cycle = false,
    this.itemCount = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
  }) : super(
            initialPage: () {
              return itemCount * ITEM_COUNT_RATIO ~/ 2 + initialPage;
            }(),
            keepPage: keepPage,
            viewportFraction: viewportFraction);
}

ValueChanged<int> _onPageChangedWrapper(ValueChanged<int> valueChanged,
    int itemCount, bool cycle, PageControllerExt controllerExt) {
  if (cycle) {
    return (int index) {
      valueChanged(index % itemCount);
      print(index);
      if (index == 0) {
        controllerExt?._superJumpToPage(itemCount * ITEM_COUNT_RATIO ~/ 2);
      } else if (index == itemCount * ITEM_COUNT_RATIO - 1) {
        controllerExt?._superJumpToPage(
            itemCount * ITEM_COUNT_RATIO ~/ 2 + itemCount - 1);
      }
    };
  }
  return valueChanged;
}

IndexedWidgetBuilder _itemBuilderWrapper(
    IndexedWidgetBuilder builder, int itemCount, bool cycle) {
  if (cycle) {
    return (BuildContext context, int index) {
      return builder?.call(context, index % itemCount);
    };
  }
  return builder;
}
