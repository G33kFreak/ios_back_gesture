import 'package:flutter/material.dart';
import 'package:ios_will_pop_scope/ios_will_pop_scope.dart';
import 'package:ios_will_pop_scope/src/consts.dart';
import 'package:ios_will_pop_scope/src/ios_back_gesture_detector.dart';
import 'package:ios_will_pop_scope/src/utils.dart';

class IosPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings is IosRouteSettings &&
        (route.settings as IosRouteSettings).onWillPop != null) {
      // Check if the route has an animation that's currently participating
      // in a back swipe gesture.
      //
      // In the middle of a back gesture drag, let the transition be linear to
      // match finger motions.
      final bool useLinearTransition = isPopGestureInProgress(route);

      return IosPageTransition(
        linearTransition: useLinearTransition,
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        child: IosBackGestureDetector(
          enabledCallback: () => isPopGestureEnabled(route),
          onStartPopGesture: () => startPopGesture(route),
          child: child,
        ),
      );
    } else {
      return const CupertinoPageTransitionsBuilder().buildTransitions(
        route,
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }
  }
}

class IosPageTransition extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  final Animation<double> primaryRouteAnimation;
  final Animation<double> secondaryRouteAnimation;
  final bool linearTransition;

  const IosPageTransition({
    Key? key,
    required this.linearTransition,
    required this.primaryRouteAnimation,
    required this.secondaryRouteAnimation,
    required this.child,
  }) : super(key: key);

  Animation<Offset> get _primaryPositionAnimation => (linearTransition
          ? primaryRouteAnimation
          : CurvedAnimation(
              // The curves below have been rigorously derived from plots of native
              // iOS animation frames. Specifically, a video was taken of a page
              // transition animation and the distance in each frame that the page
              // moved was measured. A best fit bezier curve was the fitted to the
              // point set, which is linearToEaseIn. Conversely, easeInToLinear is the
              // reflection over the origin of linearToEaseIn.
              parent: primaryRouteAnimation,
              curve: Curves.linearToEaseOut,
              reverseCurve: Curves.easeInToLinear,
            ))
      .drive(kRightMiddleTween);

  Animation<Offset> get _secondaryPositionAnimation => (linearTransition
          ? secondaryRouteAnimation
          : CurvedAnimation(
              parent: secondaryRouteAnimation,
              curve: Curves.linearToEaseOut,
              reverseCurve: Curves.easeInToLinear,
            ))
      .drive(kMiddleLeftTween);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final TextDirection textDirection = Directionality.of(context);
    return SlideTransition(
      position: _secondaryPositionAnimation,
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: _primaryPositionAnimation,
        textDirection: textDirection,
        child: child,
      ),
    );
  }
}
