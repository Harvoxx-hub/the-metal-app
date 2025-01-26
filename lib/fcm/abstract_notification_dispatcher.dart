// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:metal/main.dart';

import 'models/notification_payload_model.dart';

abstract class AbstractNotificationDispatcher {
  NavigatorState? navState;

  Future? dispatchNotification(
    NotificationPayloadModel? model, {
    bool removeUntil = false,
  });

  // Future? openPage(
  //   String routeName, {
  //   Object? argument,
  //   bool removeUntil = false,
  //   RoutePredicate? removeUntilPredicate,
  // }) {
  //   if (removeUntil) {
  //     if (removeUntilPredicate != null) {
  //       return nav?.pushNamedAndRemoveUntil(
  //         routeName,
  //         removeUntilPredicate,
  //         arguments: argument,
  //       );
  //     }

  //     return nav?.pushNamed(routeName, arguments: argument);
  //   } else {
  //     return nav?.pushNamed(routeName, arguments: argument);
  //   }
  // }
}

class PushDispatcher {
  PushDispatcher._(this._dispatcher);

  static late final PushDispatcher _instance;
  static bool _initialized = false;

  final AbstractNotificationDispatcher _dispatcher;

  static void initialize(AbstractNotificationDispatcher dispatcher) {
    _instance = PushDispatcher._(dispatcher);
    _initialized = true;
  }

  static Future? dispatchNotification(
    NotificationPayloadModel? model, {
    bool removeUntil = false,
  }) {
    assert(
      _initialized,
      'Implementation of [AbstractNotificationDispatcher]'
      'was not initialized for current app in main.dart file.',
    );

    return _instance._dispatcher
        .dispatchNotification(model, removeUntil: removeUntil);
  }
}
