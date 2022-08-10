// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/cupertino.dart';
import 'package:ios_will_pop_scope/ios_will_pop_scope.dart';
import 'package:ios_will_pop_scope/src/ios_back_gesture_detector_controller.dart';

bool isPopGestureInProgress(PageRoute<dynamic> route) {
  return route.navigator!.userGestureInProgress;
}

bool isPopGestureEnabled<T>(PageRoute<T> route) {
  // If there's nothing to go back to, then obviously we don't support
  // the back gesture.
  if (route.isFirst) return false;
  // If the route wouldn't actually pop if we popped it, then the gesture
  // would be really confusing (or would skip internal routes), so disallow it.
  if (route.willHandlePopInternally) return false;
  // If attempts to dismiss this route might be vetoed such as in a page
  // with forms, then do not allow the user to dismiss the route with a swipe.
  if (route.hasScopedWillPopCallback) return false;
  // Fullscreen dialogs aren't dismissible by back swipe.
  if (route.fullscreenDialog) return false;
  // If we're in an animation already, we cannot be manually swiped.
  if (route.animation!.status != AnimationStatus.completed) return false;
  // If we're being popped into, we also cannot be swiped until the pop above
  // it completes. This translates to our secondary animation being
  // dismissed.
  if (route.secondaryAnimation!.status != AnimationStatus.dismissed) {
    return false;
  }
  // If we're in a gesture already, we cannot start another.
  if (isPopGestureInProgress(route)) return false;

  // Looks like a back gesture would be welcome!
  return true;
}

IosBackGestureController<T> startPopGesture<T>(PageRoute<T> route) {
  assert(isPopGestureEnabled(route));

  final onWillPop = (route.settings as IosRouteSettings).onWillPop;

  return IosBackGestureController<T>(
    navigator: route.navigator!,
    controller: route.controller!,
    onWillPop: onWillPop, // protected access
  );
}
