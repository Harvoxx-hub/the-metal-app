// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectionModel _$ConnectionModelFromJson(Map<String, dynamic> json) =>
    ConnectionModel(
      connectionId: json['connectionId'] as String,
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      connectedOn: json['connectedOn'] as String,
      status: json['status'] as String? ?? 'active',
      lastMessage: json['lastMessage'] as String?,
      lastUpdatedAt: json['lastUpdatedAt'] as String?,
      game: json['game'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      otherUser: json['otherUser'] == null
          ? null
          : UserModel.fromJson(json['otherUser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConnectionModelToJson(ConnectionModel instance) =>
    <String, dynamic>{
      'connectionId': instance.connectionId,
      'users': instance.users,
      'lastMessage': instance.lastMessage,
      'lastUpdatedAt': instance.lastUpdatedAt,
      'game': instance.game,
      'connectedOn': instance.connectedOn,
      'status': instance.status,
      'isAnonymous': instance.isAnonymous,
      'otherUser': instance.otherUser?.toJson(),
    };
