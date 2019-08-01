import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ValueListener<T> extends StatefulWidget {
  final Widget child;
  final ValueChanged<T> valueChanged;
  final ValueListenable<T> valueListenable;

  ValueListener(
      {@required this.child,
      this.valueChanged,
      @required this.valueListenable});

  @override
  _ValueListenerState<T> createState() {
    return _ValueListenerState<T>();
  }
}

class _ValueListenerState<T> extends State<ValueListener<T>> {
  @override
  void initState() {
    super.initState();
    _valueChanged();
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ValueListener<T> oldWidget) {
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      _valueChanged();
      widget.valueListenable.addListener(_valueChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _valueChanged() {
    widget.valueChanged?.call(widget.valueListenable.value);
  }
}
