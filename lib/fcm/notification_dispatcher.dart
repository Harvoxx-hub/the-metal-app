import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/auth.pref.service.dart';
 
import 'package:metal/route/routes.dart';

import 'abstract_notification_dispatcher.dart';
import 'models/notification_payload_model.dart';
import 'models/push_type.dart';
///TODO Woek on notification 
class NotificationDispatcher extends AbstractNotificationDispatcher {
  @override
  Future? dispatchNotification(
    NotificationPayloadModel? model, {
    bool removeUntil = false,
  }) {
    // if (_isUserAuthorized() && model != null) {

    //   if (model.action != null) {

    //     return openPage(
    //       Dashboard.name,
    //       removeUntil: true,
    //       removeUntilPredicate: ModalRoute.withName(
    //         Dashboard.name,
    //       ),
    //     );
    //   } else {
    //    print('model == null');
    //   }
    // } else {
    //   print('model == null');
    // }

    return handleNavigation(model);
  }

  Future<void> _onAction(NotificationPayloadModel model) async {
    print('on action nut null');
    // TODO starter: implement handles of push types if needed

    switch (model.action) {
      case PushType.message:
        // await openPage(
        //   AppRoutes.chatWindowsPage,
        //   removeUntil: true,
        //   argument: model.id,
        //   removeUntilPredicate: ModalRoute.withName(
        //     AppRoutes.chatWindowsPage,
        //   ),
        // );
        break;

      // case PushType.follow:
      //   await openPage(
      //     SecoundaryProfile.name,
      //     removeUntil: true,
      //     argument: model.id,
      //     removeUntilPredicate: ModalRoute.withName(
      //       Dashboard.name,
      //     ),
      //   );
      //   break;
      // case PushType.likePost:
      //   await openPage(
      //     CommentPage.name,
      //     removeUntil: true,
      //     argument: getPost(model.id),
      //     removeUntilPredicate: ModalRoute.withName(
      //       CommentPage.name,
      //     ),
      //   );
      //   break;

      // case PushType.message:
      //   await openPage(
      //     ChatDetails.name,
      //     removeUntil: true,
      //     argument: model.id.toString(),
      //     removeUntilPredicate: ModalRoute.withName(
      //       Dashboard.name,
      //     ),
      //   );
      //   break;
      default:
        print('default');
    }
  }

 

  final container = ProviderContainer();

  Future<bool> _isUserAuthorized() async =>
      await AuthManager.getLoginState() == LoginState.loggedIn;

  Future<void> handleNavigation(NotificationPayloadModel? model) async {
    if (await _isUserAuthorized()) {
      if (model!.action != null) {
        // return openPage(
        //   AppRoutes.dashboardPage,
        //   removeUntil: true,
        //   removeUntilPredicate: ModalRoute.withName(
        //     AppRoutes.dashboardPage,
        //   ),
        // );
      } else {
        print('model.action == null');
      }
    } else {
      print('!_isUserAuthorized()');
    }

    return;
  }
}
