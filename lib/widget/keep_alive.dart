import 'package:flutter/cupertino.dart';

class KeepAliveContainer extends StatefulWidget {
  final Widget child;

  KeepAliveContainer({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _KeepAliveState();
  }
}

class _KeepAliveState extends State<KeepAliveContainer>
    with AutomaticKeepAliveClientMixin<KeepAliveContainer> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
