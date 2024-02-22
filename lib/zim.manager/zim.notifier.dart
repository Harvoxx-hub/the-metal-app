import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:zego_zim/zego_zim.dart';

class ZimNotifier {
  ZimNotifier(
    this.ref,
  ) {}
  final Ref ref;

  //start conversation
  void startConversation(
    String toConversationID,
    String message,
  ) async {
    try {
      // 3. Send messages.
      ZIMTextMessage textMessage = ZIMTextMessage(message: "message");
      ZIMMessageSendConfig sendConfig = ZIMMessageSendConfig();
// Set the message priority.
      sendConfig.priority = ZIMMessagePriority.low;

      ZIMPushConfig pushConfig = ZIMPushConfig();
      pushConfig.title = "Offline notification title";
      pushConfig.content = "Offline notification content";

      sendConfig.pushConfig = pushConfig;
      ZIMMessageSendNotification notification =
          ZIMMessageSendNotification(onMessageAttached: (message) {
        // The callback on the message not sent yet. Before the message is sent, you can get a temporary ZIMMessage message for you to implement your business logic as needed.
      });

// 4. Set conversation type. Set it based on your conversation type.
// Send one-on-one messages.
      ZIMConversationType type = ZIMConversationType.peer;

      ZIM
          .getInstance()!
          .sendMessage(textMessage, "toConversationID", type, sendConfig)
          .then((value) {
        print(value);
      }).catchError((onError) {
        // You can use this to error info of the message sending failure.
        print(onError);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //send message
}

final zimProvider = Provider.autoDispose<ZimNotifier>(
  (ref) => ZimNotifier(ref),
);
