

// todo starter: update Android push model
import 'push_type.dart';

class AndroidPushModel {
  AndroidPushModel({this.notification, this.data});

  AndroidPushModel.fromJson(Map<String, dynamic> json) {
    notification = json['notification'] != null
        ? Notification.fromJson(Map<String, dynamic>.from(json['notification']))
        : null;
    data = json['data'] != null
        ? Data.fromJson(Map<String, dynamic>.from(json['data']))
        : null;
  }

  Notification? notification;
  Data? data;
}

class Notification {
  Notification({this.title, this.body});

  Notification.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
  }

  String? title;
  String? body;
}

class Data {
  Data({this.type, this.clickAction});

  Data.fromJson(Map<String, dynamic> json) {
    type = PushType.valueOf(json['type']);
    clickAction = json['click_action'];
  }

  PushType? type;
  String? clickAction;
}
