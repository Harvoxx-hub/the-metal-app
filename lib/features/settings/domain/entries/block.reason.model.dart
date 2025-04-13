import 'package:json_annotation/json_annotation.dart';

class BlockReasonModel {
  final String id;
  final String userId;
  final String blockedUserId;
  final String reasonCode;
  final String? customReason;
  final String? reportDetails;
  final bool isReported;
  final String timestamp;

  BlockReasonModel({
    required this.id,
    required this.userId,
    required this.blockedUserId,
    required this.reasonCode,
    this.customReason,
    this.reportDetails,
    this.isReported = false,
    required this.timestamp,
  });

  // Manual serialization
  factory BlockReasonModel.fromJson(Map<String, dynamic> json) {
    return BlockReasonModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      blockedUserId: json['blockedUserId'] as String,
      reasonCode: json['reasonCode'] as String,
      customReason: json['customReason'] as String?,
      reportDetails: json['reportDetails'] as String?,
      isReported: json['isReported'] as bool? ?? false,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'blockedUserId': blockedUserId,
        'reasonCode': reasonCode,
        'customReason': customReason,
        'reportDetails': reportDetails,
        'isReported': isReported,
        'timestamp': timestamp,
      };
}

// Define standard block reason codes for categorization
enum BlockReasonCode {
  harassment,
  inappropriate_content,
  spam,
  fake_profile,
  unwanted_contact,
  other
}

// Extension to get readable display text
extension BlockReasonCodeExtension on BlockReasonCode {
  String get displayName {
    switch (this) {
      case BlockReasonCode.harassment:
        return 'Harassment';
      case BlockReasonCode.inappropriate_content:
        return 'Inappropriate Content';
      case BlockReasonCode.spam:
        return 'Spam';
      case BlockReasonCode.fake_profile:
        return 'Fake Profile';
      case BlockReasonCode.unwanted_contact:
        return 'Unwanted Contact';
      case BlockReasonCode.other:
        return 'Other';
    }
  }
}
