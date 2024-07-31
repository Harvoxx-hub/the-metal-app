import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:metal/core/utils/timestamp_converter.dart';

part 'message.model.g.dart';

enum MessageType { text, audio }

enum MessageState { sending, sent, read, error }

@JsonSerializable()
class MessageModel {
  final String message;
  final String senderId;
  final String recipientId;
  final MessageType type;
  String? content;
   String? userName;
    String? fcmToken;
  @TimestampConverter()
  final DateTime timestamp;
  final MessageState state;

  MessageModel({
    required this.message,
    required this.recipientId,
    required this.senderId,
    required this.type,
    this.content,
    this.userName,
    this.fcmToken,
    required this.timestamp,
    required this.state,
  });
  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
  factory MessageModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return MessageModel(
      message: data['message'] ?? '',
      senderId: data['senderId'] ?? '',
      recipientId: data['recipientId'] ?? '',
      type: _convertStringToMessageType(data['type'] ?? ''),
      content: data['content'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      state: _convertStringToMessageState(data['state'] ?? ''),
    );
  }

  static MessageType _convertStringToMessageType(String type) {
    return type == 'text' ? MessageType.text : MessageType.audio;
  }

  static MessageState _convertStringToMessageState(String state) {
    switch (state) {
      case 'sending':
        return MessageState.sending;
      case 'sent':
        return MessageState.sent;
      case 'read':
        return MessageState.read;
      default:
        return MessageState.error;
    }
  }
}
