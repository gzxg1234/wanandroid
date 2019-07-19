import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef Widget MultiValueListenableWidgetBuilder(
    BuildContext context, List<dynamic> values, Widget child);

class MultiValueListenableBuilder extends StatelessWidget {
  final List<ValueListenable> valueListenableList;
  final MultiValueListenableWidgetBuilder builder;
  final Widget child;

  const MultiValueListenableBuilder({
    Key key,
    @required this.builder,
    this.child,
    this.valueListenableList,
  })  : assert(valueListenableList != null && valueListenableList.length > 0),
        assert(builder != null);

  @override
  Widget build(BuildContext context) {
    return buildTree(valueListenableList,
        List<dynamic>(valueListenableList.length), builder, 0);
  }

  Widget buildTree(List<ValueListenable> streams, List<dynamic> values,
      MultiValueListenableWidgetBuilder builder, int i) {
    return ValueListenableBuilder(
      valueListenable: valueListenableList[i],
      builder: (context, value, child) {
        values[i] = value;
        if (i == streams.length - 1) {
          return builder(context, values, this.child);
        }
        return buildTree(streams, values, builder, i + 1);
      },
    );
  }
}

typedef Widget MultiStreamWidgetBuilder(
    BuildContext context, List<AsyncSnapshot> snaps);

class MultiStreamBuilder extends StatelessWidget {
  final List<Stream> streams;
  final MultiStreamWidgetBuilder builder;

  const MultiStreamBuilder({
    Key key,
    @required this.builder,
    this.streams,
  })  : assert(streams != null && streams.length > 0),
        assert(builder != null);

  @override
  Widget build(BuildContext context) {
    return buildTree(streams, List<AsyncSnapshot>(streams.length), builder, 0);
  }

  Widget buildTree(List<Stream> streams, List<AsyncSnapshot> snapshots,
      MultiStreamWidgetBuilder builder, int i) {
    return StreamBuilder(
      stream: streams[i],
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        snapshots[i] = snapshot;
        if (i == streams.length - 1) {
          return builder(context, snapshots);
        }
        return buildTree(streams, snapshots, builder, i + 1);
      },
    );
  }
}
