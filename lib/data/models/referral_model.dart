import 'package:metal/domain/entities/referral_dto.dart';

/// Referral model for API responses
class ReferralModel {
  final String referralCode;
  final int referralCount;
  final int sparksEarned;
  final List<ReferralHistoryModel> history;

  ReferralModel({
    required this.referralCode,
    required this.referralCount,
    required this.sparksEarned,
    required this.history,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      referralCode: json['referralCode'] as String? ?? '',
      referralCount: json['referralCount'] as int? ?? 0,
      sparksEarned: json['sparksEarned'] as int? ?? 0,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => ReferralHistoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  ReferralDto toDomain() {
    return ReferralDto(
      referralCode: referralCode,
      referralCount: referralCount,
      sparksEarned: sparksEarned,
      history: history.map((e) => e.toDomain()).toList(),
    );
  }
}

/// Referral history item model
class ReferralHistoryModel {
  final String id;
  final String referredUserId;
  final String? referredUserName;
  final int sparksAwarded;
  final String createdAt;

  ReferralHistoryModel({
    required this.id,
    required this.referredUserId,
    this.referredUserName,
    required this.sparksAwarded,
    required this.createdAt,
  });

  factory ReferralHistoryModel.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryModel(
      id: json['id'] as String? ?? '',
      referredUserId: json['referredUserId'] as String? ?? '',
      referredUserName: json['referredUserName'] as String?,
      sparksAwarded: json['sparksAwarded'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  ReferralHistoryDto toDomain() {
    return ReferralHistoryDto(
      id: id,
      referredUserId: referredUserId,
      referredUserName: referredUserName,
      sparksAwarded: sparksAwarded,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
