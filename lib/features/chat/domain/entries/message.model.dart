import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:metal/core/utils/timestamp_converter.dart';

part 'message.model.g.dart';

enum MessageType { text, audio, un_melt }

enum MessageState { sending, sent, read, error }

@JsonSerializable()
class MessageModel {
  final String message;
  final String senderId;

  final MessageType type;
  String? content;
   String? id;

  final String timestamp;
  final bool isRead;

  MessageModel({
    required this.message,
    required this.senderId,
    required this.type,
    this.content,
     this.id,
    required this.timestamp,
    required this.isRead,
  });
  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
  factory MessageModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return MessageModel(
      message: data['message'] ?? '',
      senderId: data['senderId'] ?? '',
      type: _convertStringToMessageType(data['type'] ?? ''),
      content: data['content'],
      timestamp: data['timestamp'],
      isRead: data['isRead'],
      id: snapshot.id
    );
  }

  static MessageType _convertStringToMessageType(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'audio':
        return MessageType.audio;
      case 'un_melt':
        return MessageType.un_melt;
      default:
        throw ArgumentError('Unknown message type: $type');
    }
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
