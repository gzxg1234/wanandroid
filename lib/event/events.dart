///首页tab显示刷新图标
class MainTabShowRefreshEvent {
  final int index;
  final bool show;

  MainTabShowRefreshEvent(this.index, this.show);
}

///首页tab重复按下事件
class MainTabReTapEvent {
  final int index;

  MainTabReTapEvent(this.index);
}

///切换首页tab
class SwitchHomeTabEvent {
  final int index;

  SwitchHomeTabEvent(this.index);
}

///跳转指定分类页面
class JumpCategoryEvent {
  final int childCatId;

  JumpCategoryEvent(this.childCatId);
}
