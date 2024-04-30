 

// todo starter: update iOS push model
import 'push_type.dart';

class IOSPushModel {
  IOSPushModel({
    this.clickAction,
    this.type,
    this.notification,
  });

  IOSPushModel.fromJson(Map<String, dynamic> json) {
    clickAction = json['click_action'];
    type = PushType.valueOf(json['type']);
    notification = json['notification'] != null
        ? Notification.fromJson(Map<String, dynamic>.from(json['notification']))
        : Notification.fromJson(
            Map<String, dynamic>.from(json['aps']['alert']),
          );
  }

  String? clickAction;
  PushType? type;
  Notification? notification;
}

class Notification {
  Notification({
    this.title,
    this.entity,
    this.body,
  });

  Notification.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    entity = json['e'];
    body = json['body'];
  }

  String? title;
  String? entity;
  String? body;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['title'] = title;
    json['e'] = entity;
    json['body'] = body;

    return json;
  }
}
