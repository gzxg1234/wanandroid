import 'package:flutter/widgets.dart';

typedef Widget ItemBuilder(BuildContext context, int index, bool active);


///指示器
class PageIndicator extends StatefulWidget {
  final ItemBuilder itemBuilder;
  final int currentItem;
  final int itemCount;
  final double margin;

  PageIndicator(
      {this.itemBuilder, this.margin = 4, this.currentItem, this.itemCount});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<PageIndicator> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<Widget> children = [];
    for (int i = 0; i < widget.itemCount; i++) {
      children.add(Container(
          margin:
              i == 0 ? EdgeInsets.zero : EdgeInsets.only(left: widget.margin),
          child: widget.itemBuilder(context, i, i == widget.currentItem)));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
