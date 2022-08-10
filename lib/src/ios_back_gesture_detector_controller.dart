import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ios_will_pop_scope/src/consts.dart';

class IosBackGestureController<T> {
  /// Creates a controller for an iOS-style back gesture.
  ///
  /// The [navigator] and [controller] arguments must not be null.
  IosBackGestureController({
    required this.navigator,
    required this.controller,
    this.onWillPop,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;
  final Future<bool> Function()? onWillPop;

  /// The drag gesture has changed by [fractionalDelta]. The total range of the
  /// drag should be 0.0 to 1.0.
  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  /// The drag gesture has ended with a horizontal motion of
  /// [fractionalVelocity] as a fraction of screen width per second.
  Future<void> dragEnd(double velocity) async {
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to
    // take at least one frame.
    //
    // This curve has been determined through rigorously eyeballing native iOS
    // animations.
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    final bool animateForward;

    // If the user releases the page before mid screen with sufficient velocity,
    // or after mid screen, we should animate the page out. Otherwise, the page
    // should be animated back in.
    if (velocity.abs() >= kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      fowardAnimation(animationCurve);
    } else {
      // This route is destined to pop at this point. Reuse navigator's pop.
      if (onWillPop != null) {
        final needPop = await onWillPop!();

        if (needPop) {
          navigator.pop();
          popNavigationAnimation(animationCurve);
        } else {
          fowardAnimation(animationCurve);
        }
      } else {
        navigator.pop();
        popNavigationAnimation(animationCurve);
      }
    }

    if (controller.isAnimating) {
      // Keep the userGestureInProgress in true state so we don't change the
      // curve of the page transition mid-flight since IosPageTransition
      // depends on userGestureInProgress.
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }

  void popNavigationAnimation(Curve animationCurve) {
    if (controller.isAnimating) {
      // Otherwise, use a custom popping animation duration and curve.
      final int droppedPageBackAnimationTime = lerpDouble(
        0,
        kMaxDroppedSwipePageForwardAnimationTime,
        controller.value,
      )!
          .floor();

      controller.animateBack(
        0.0,
        duration: Duration(milliseconds: droppedPageBackAnimationTime),
        curve: animationCurve,
      );
    }
  }

  // The popping may have finished inline if already at the target destination.
  void fowardAnimation(Curve animationCurve) {
    // The closer the panel is to dismissing, the shorter the animation is.
    // We want to cap the animation time, but we want to use a linear curve
    // to determine it.
    final int droppedPageForwardAnimationTime = min(
      lerpDouble(
        kMaxDroppedSwipePageForwardAnimationTime,
        0,
        controller.value,
      )!
          .floor(),
      kMaxPageBackAnimationTime,
    );

    controller.animateTo(
      1.0,
      duration: Duration(milliseconds: droppedPageForwardAnimationTime),
      curve: animationCurve,
    );
  }
}
