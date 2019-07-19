import 'package:flutter/cupertino.dart';

typedef Widget StateWidgetBuilder(BuildContext context, int state);

class SaveStateIndexedStack extends StatefulWidget {
  final List<Widget> widgets;
  final int index;

  SaveStateIndexedStack({this.widgets, this.index = 0});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

class _State extends State<SaveStateIndexedStack> {
  Set<int> loaded = Set();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < widget.widgets.length; i++) {
      if (widget.index == i) {
        loaded.add(i);
      }
      children.add(loaded.contains(i) ? widget.widgets[i] : Container());
    }
    return IndexedStack(
      index: widget.index,
      children: children,
    );
  }
}
