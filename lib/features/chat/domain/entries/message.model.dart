import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.model.g.dart';

enum MessageType { text, audio, un_melt, calls }

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

  // Reply functionality fields
  String? replyToMessageId; // ID of the message being replied to
  String? replyToMessageText; // Truncated preview text of the original message
  String? replyToSenderId; // ID of the original message sender
  String?
      replyToMessageType; // Type of the original message (text, audio, etc.)

  MessageModel({
    required this.message,
    required this.senderId,
    required this.type,
    this.content,
    this.id,
    required this.timestamp,
    required this.isRead,
    this.replyToMessageId,
    this.replyToMessageText,
    this.replyToSenderId,
    this.replyToMessageType,
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
        id: snapshot.id,
        replyToMessageId: data['replyToMessageId'],
        replyToMessageText: data['replyToMessageText'],
        replyToSenderId: data['replyToSenderId'],
        replyToMessageType: data['replyToMessageType']);
  }

  static MessageType _convertStringToMessageType(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'audio':
        return MessageType.audio;
      case 'calls':
        return MessageType.calls;
      case 'un_melt':
        return MessageType.un_melt;
      default:
        throw ArgumentError('Unknown message type: $type');
    }
  }

  /// Check if this message is a reply to another message
  bool get isReply => replyToMessageId != null && replyToMessageId!.isNotEmpty;

  /// Get truncated reply text for display
  String get truncatedReplyText {
    if (!isReply || replyToMessageText == null) return '';

    const maxLength = 50; // Truncate to 50 characters
    if (replyToMessageText!.length <= maxLength) {
      return replyToMessageText!;
    }
    return '${replyToMessageText!.substring(0, maxLength)}...';
  }

  /// Get display text for reply preview based on message type
  String get replyPreviewText {
    if (!isReply) return '';

    switch (replyToMessageType) {
      case 'text':
        return truncatedReplyText;
      case 'audio':
        return '🎵 Voice message';
      case 'calls':
        return '📞 Call';
      case 'un_melt':
        return '🔓 Unmelt request';
      default:
        return '📎 Message';
    }
  }
}
