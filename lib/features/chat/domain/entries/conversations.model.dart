import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:metal/core/utils/timestamp_converter.dart';

part 'conversations.model.g.dart';

@JsonSerializable()
class ConversationsModel {
  final String documentId;
  @TimestampConverter()
  final DateTime initiatedAt;

  final String lastMessage;
  @TimestampConverter()
  final DateTime lastUpdatedAt;
  final List<String> participantIds;
    final String game;

  ConversationsModel({
    required this.documentId,
    required this.initiatedAt,
    required this.lastMessage,
    required this.lastUpdatedAt,
    required this.participantIds,
    required this.game
  });
  factory ConversationsModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationsModelFromJson(json);
  factory ConversationsModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return ConversationsModel(
      documentId: snapshot.id,
      game:  data['game'] ?? '',
      initiatedAt: (data['initiatedAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'] ?? '',
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
      participantIds: List<String>.from(data['participantIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => _$ConversationsModelToJson(this);
}
