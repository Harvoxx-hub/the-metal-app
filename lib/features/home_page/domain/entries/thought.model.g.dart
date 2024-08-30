// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thought.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThoughtModel _$ThoughtModelFromJson(Map<String, dynamic> json) => ThoughtModel(
      id: (json['id'] as num?)?.toInt(),
      user: json['user'] as String?,
      thought: json['thought'] as String?,
      created_at: json['created_at'] as String?,
      userData: json['userData'] == null
          ? null
          : UserData.fromJson(json['userData'] as Map<String, dynamic>),
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ThoughtModelToJson(ThoughtModel instance) =>
    <String, dynamic>{
      'created_at': instance.created_at,
      'id': instance.id,
      'user': instance.user,
      'thought': instance.thought,
      'userData': instance.userData?.toJson(),
      'reactions': instance.reactions?.map((e) => e.toJson()).toList(),
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      metal: json['metal'] == null
          ? null
          : Metal.fromJson(json['metal'] as Map<String, dynamic>),
      fullname: json['fullname'] as String?,
      username: json['username'] as String?,
      verification: json['verification'] as bool? ?? false,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'metal': instance.metal?.toJson(),
      'fullname': instance.fullname,
      'username': instance.username,
      'verification': instance.verification,
    };

Reaction _$ReactionFromJson(Map<String, dynamic> json) => Reaction(
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => ReactionUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      reaction: json['reaction'] as String?,
    );

Map<String, dynamic> _$ReactionToJson(Reaction instance) => <String, dynamic>{
      'users': instance.users?.map((e) => e.toJson()).toList(),
      'reaction': instance.reaction,
    };

ReactionUser _$ReactionUserFromJson(Map<String, dynamic> json) => ReactionUser(
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$ReactionUserToJson(ReactionUser instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
    };
