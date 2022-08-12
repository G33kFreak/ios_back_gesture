import 'package:flutter/material.dart';
import 'package:ios_will_pop_scope/ios_will_pop_scope.dart';
import 'package:ios_will_pop_scope/src/consts.dart';
import 'package:ios_will_pop_scope/src/ios_back_gesture_detector.dart';
import 'package:ios_will_pop_scope/src/utils.dart';

class IosPageRouteBuilder<T> extends PageRouteBuilder<T> {
  final IosRouteSettings? routeSettings;

  IosPageRouteBuilder({
    required super.pageBuilder,
    this.routeSettings,
  }) : super(
          fullscreenDialog: false,
          barrierDismissible: false,
          opaque: true,
          settings: routeSettings,
        );

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return pageBuilder(context, animation, secondaryAnimation);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return IosPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class IosPageTransition extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  final Animation<double> primaryRouteAnimation;
  final Animation<double> secondaryRouteAnimation;

  const IosPageTransition({
    Key? key,
    required this.primaryRouteAnimation,
    required this.secondaryRouteAnimation,
    required this.child,
  }) : super(key: key);

  @override
  State<IosPageTransition> createState() => _IosPageTransitionState();
}

class _IosPageTransitionState extends State<IosPageTransition> {
  late final ModalRoute<Object?> route;
  bool linearTransition = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    route = ModalRoute.of(context)!;
  }

  @override
  void didUpdateWidget(IosPageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    linearTransition = isPopGestureInProgress(route);
  }

  Animation<Offset> get _primaryPositionAnimation => (linearTransition
          ? widget.primaryRouteAnimation
          : CurvedAnimation(
              // The curves below have been rigorously derived from plots of native
              // iOS animation frames. Specifically, a video was taken of a page
              // transition animation and the distance in each frame that the page
              // moved was measured. A best fit bezier curve was the fitted to the
              // point set, which is linearToEaseIn. Conversely, easeInToLinear is the
              // reflection over the origin of linearToEaseIn.
              parent: widget.primaryRouteAnimation,
              curve: Curves.linearToEaseOut,
              reverseCurve: Curves.easeInToLinear,
            ))
      .drive(kRightMiddleTween);

  Animation<Offset> get _secondaryPositionAnimation => (linearTransition
          ? widget.secondaryRouteAnimation
          : CurvedAnimation(
              parent: widget.secondaryRouteAnimation,
              curve: Curves.linearToEaseOut,
              reverseCurve: Curves.easeInToLinear,
            ))
      .drive(kMiddleLeftTween);

  @override
  Widget build(BuildContext context) {
    if (needToUseIosWillPop(route)) {
      assert(debugCheckHasDirectionality(context));
      final TextDirection textDirection = Directionality.of(context);
      return SlideTransition(
        position: _secondaryPositionAnimation,
        textDirection: textDirection,
        transformHitTests: false,
        child: SlideTransition(
          position: _primaryPositionAnimation,
          textDirection: textDirection,
          child: IosBackGestureDetector(
            enabledCallback: () => isPopGestureEnabled(route),
            onStartPopGesture: () => startPopGesture(route),
            child: widget.child,
          ),
        ),
      );
    } else {
      return WillPopScope(
        onWillPop: route.settings is IosRouteSettings
            ? (route.settings as IosRouteSettings).onWillPop
            : () => Future.value(true),
        child: Theme.of(context).pageTransitionsTheme.buildTransitions(
              route as PageRoute,
              context,
              widget.primaryRouteAnimation,
              widget.secondaryRouteAnimation,
              widget.child,
            ),
      );
    }
  }
}
