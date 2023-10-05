import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum NavigationEventType {
  push,
  pop,
  remove,
  replace,
}

class NavigationEvent {
  NavigationEvent({
    required this.previousRoute,
    required this.fullPath,
    this.route,
    this.type,
  });

  final Route? route;
  final Route? previousRoute;
  final NavigationEventType? type;
  final String fullPath;

  String? get previousRouteName => previousRoute?.settings.name;

  String? get routeName => route?.settings.name;

  // ignore:no-object-declaration
  Object? get previousRouteArgs => previousRoute?.settings.arguments;

  // ignore:no-object-declaration
  Object? get newRouteArgs => route?.settings.arguments;

  @override
  String toString() {
    final type = this.type;

    return {
      'type': type != null ? describeEnum(type) : '',
      'fullPath': fullPath,
      'routeName': routeName,
      'routeArgs': newRouteArgs,
      'previousRouteName': previousRouteName,
      'previousRouteArgs': previousRouteArgs,
    }.toString();
  }
}
