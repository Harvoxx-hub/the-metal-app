import 'package:json_annotation/json_annotation.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/upgrade/domain/entries/metal.plan.model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification.model.g.dart';

enum NotificationType {
  MELT,
  SPARK,
  REFER,
  MESSAGE,
  UNMELT,
}

@JsonSerializable(explicitToJson: true)
class NotificationModel {
  final int? id;
  final String? created_at;
  final NotificationType? type;
  final String? fcmToken;
  final String? title;
  final String? body;
  final String? sender;
  // final String? username;
  final String? receiver;

  NotificationModel({
    this.id,
    this.created_at,
    this.type,
    this.fcmToken,
    this.title,
    this.body,
    this.sender,
    this.receiver,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
