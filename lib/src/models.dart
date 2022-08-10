import 'package:flutter/material.dart';

class IosRouteSettings extends RouteSettings {
  final Future<bool> Function()? onWillPop;

  const IosRouteSettings({String? name, Object? arguments, this.onWillPop})
      : super(arguments: arguments, name: name);
}
