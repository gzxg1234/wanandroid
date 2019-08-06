///首页tab显示刷新图标
class MainTabShowRefreshEvent {
  final int index;
  final bool show;

  MainTabShowRefreshEvent(this.index, this.show);
}

///首页tab重复按下事件
class MainTabReTapEvent{
  final int index;

  MainTabReTapEvent(this.index);
}