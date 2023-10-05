import 'dart:async';

 
import 'package:flutter/material.dart';

import 'navigation_event.dart';

export 'navigation_event.dart';

///Observer for navigation to use in test
class CRNavigatorObserver extends NavigatorObserver {
  String fullPath = '';

  final _routeEventStream = StreamController<NavigationEvent>();

  @override
  void didPush(Route route, Route? previousRoute) {
    fullPath += route.settings.name ?? '';

    _routeEventStream.add(
      NavigationEvent(
        route: route,
        fullPath: fullPath,
        previousRoute: previousRoute,
        type: NavigationEventType.push,
      ),
    );
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final old = oldRoute?.settings.name;
    if (old != null) {
      fullPath = fullPath.replaceFirst(old, newRoute?.settings.name ?? '');
    }

    _routeEventStream.add(
      NavigationEvent(
        route: newRoute,
        fullPath: fullPath,
        previousRoute: oldRoute,
        type: NavigationEventType.replace,
      ),
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final removePath = route.settings.name;
    if (removePath != null) {
      fullPath = fullPath.replaceFirst(removePath, '');
    }

    _routeEventStream.add(
      NavigationEvent(
        route: route,
        fullPath: fullPath,
        previousRoute: previousRoute,
        type: NavigationEventType.pop,
      ),
    );
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    final removePath = route.settings.name;
    if (removePath != null) {
      fullPath = fullPath.replaceFirst(removePath, '');
    }

    _routeEventStream.add(
      NavigationEvent(
        route: route,
        fullPath: fullPath,
        previousRoute: previousRoute,
        type: NavigationEventType.remove,
      ),
    );
    super.didRemove(route, previousRoute);
  }

  void listen(NavigationEventCallback listener) {
    _routeEventStream.stream.asBroadcastStream().listen(listener);
  }

  void dispose() {
    _routeEventStream.close();
  }
}

typedef NavigationEventCallback = Function(NavigationEvent event);
