import 'package:flutter/material.dart';

/// An enhanced version of [WillPopScope] that adds additional functionality.
class IosWillPopScope extends StatefulWidget {
  /// Creates a widget that registers a callback to veto attempts by the user to
  /// dismiss the enclosing [ModalRoute].
  ///
  /// The `child` argument must not be `null`.
  const IosWillPopScope({
    Key? key,
    required this.child,
    required this.onWillPop,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// Called to veto attempts by the user to dismiss the enclosing [ModalRoute].
  ///
  /// If the callback returns a [Future] that resolves to `false`, the enclosing
  /// route will not be popped.
  final WillPopCallback? onWillPop;

  @override
  State<IosWillPopScope> createState() => _IosWillPopScopeState();
}

bool isPopGestureInProgress(ModalRoute<Object?> route) {
  return route.navigator!.userGestureInProgress;
}

class _IosWillPopScopeState extends State<IosWillPopScope> {
  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.onWillPop != null) {
      // Remove callback from the "old" route.
      _route?.removeScopedWillPopCallback(widget.onWillPop!);

      // Update the reference to the "current" route.
      _route = ModalRoute.of(context);

      _route?.addScopedWillPopCallback(widget.onWillPop!);
    }
  }

  @override
  void didUpdateWidget(IosWillPopScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    assert(_route == ModalRoute.of(context));

    if (widget.onWillPop != oldWidget.onWillPop) {
      // Remove callbacks of the old widget state.
      if (oldWidget.onWillPop != null) {
        _route?.removeScopedWillPopCallback(oldWidget.onWillPop!);
      }

      _route?.addScopedWillPopCallback(widget.onWillPop!);
    }
  }

  @override
  void dispose() {
    if (widget.onWillPop != null) {
      _route?.removeScopedWillPopCallback(widget.onWillPop!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
