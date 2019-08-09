import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid/component/more_tab_window.dart';
import 'package:wanandroid/util/auto_size.dart';
import 'package:wanandroid/widget/rotation_view.dart';

import '../main.dart';

class TabPager extends StatefulWidget {
  final List<String> tabs;
  final ValueChanged<int> onTabReTap;
  final ValueChanged<int> onTabChange;
  final IndexedWidgetBuilder pageBuilder;
  final int initialIndex;

  TabPager(
      {Key key,
      this.tabs,
      this.onTabReTap,
      this.pageBuilder,
      this.onTabChange,
      this.initialIndex = 0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TabPagerState();
  }
}

class TabPagerState extends State<TabPager> with TickerProviderStateMixin {
  GlobalKey<RotationViewState> _dropDownButtonKey = GlobalKey();

  TabController _tabController;
  PageController _pageController;
  bool _tabChangeFromPage = false;
  MoreTabWindow _moreTabWindow;
  final GlobalKey _tabBarKey = GlobalKey();
  bool _pageAnimateRunning = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    _tabController?.dispose();
    _pageController?.dispose();
    _tabController = TabController(
        vsync: this,
        length: widget.tabs.length,
        initialIndex: widget.initialIndex);
    _tabController.addListener(() {
      widget.onTabChange?.call(_tabController.index);
      if (!_tabChangeFromPage) {
        //PageView的animateToPage经过的页面都会触发onPageChanged，做个标记防止onPageChange循环触发
        _pageAnimateRunning = true;
        _pageController
            .animateToPage(_tabController.index,
                duration: Duration(milliseconds: 300), curve: Curves.ease)
            .whenComplete(() {
          _pageAnimateRunning = false;
        });
      } else {
        _tabChangeFromPage = false;
      }
    });
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void jumpTo(int index) {
    _tabController.index = index;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: MyApp.getTheme(context).primaryColor,
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TabBar(
                      key: _tabBarKey,
                      isScrollable: true,
                      onTap: (index) {
                        if (!_tabController.indexIsChanging) {
                          widget.onTabReTap?.call(index);
                        }
                      },
                      //是否可以滚动
                      controller: _tabController,
                      labelColor: MyApp.getTheme(context).tabBarSelectedColor,
                      unselectedLabelColor:
                          MyApp.getTheme(context).tabBarUnSelectedColor,
                      indicatorColor: MyApp.getTheme(context).tabBarSelectedColor,
                      labelStyle: TextStyle(fontSize: sizeW(14)),
                      tabs: () {
                        return widget.tabs
                            .map((e) => Tab(
                                  text: e,
                                ))
                            .toList();
                      }())),
              Offstage(
                offstage: widget.tabs.length < 5,
                child: Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    containedInkWell: true,
                    customBorder: CircleBorder(),
                    onTap: () {
                      _dropDownButtonKey.currentState?.forward();
                      _showMoreCat(widget.tabs);
                    },
                    child: SizedBox(
                        width: 46,
                        height: 46,
                        child: RotationView(
                          key: _dropDownButtonKey,
                          fromDegree: 0,
                          toDegree: -180,
                          duration: Duration(milliseconds: 300),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: MyApp.getTheme(context).appBarTextIconColor,
                          ),
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
              itemCount: widget.tabs.length,
              controller: _pageController,
              onPageChanged: (index) {
                if (!_pageAnimateRunning) {
                  //flag标记防止tab的change又调用page.jumpage
                  _tabChangeFromPage = true;
                  _tabController?.index = index;
                }
              },
              itemBuilder: widget.pageBuilder),
        )
      ],
    );
  }

  void _showMoreCat(List<String> list) {
    _moreTabWindow = MoreTabWindow(List.from(list), _tabController.index);
    _moreTabWindow
        .showAsDropdown(targetContext: _tabBarKey.currentContext)
        .then((index) {
      _dropDownButtonKey.currentState?.reverse();
      if (index != null) {
        _tabController?.index = index;
      }
    });
  }
}
