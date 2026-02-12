/// Referral information DTO
class ReferralDto {
  final String referralCode;
  final int referralCount;
  final int sparksEarned;
  final List<ReferralHistoryDto> history;

  ReferralDto({
    required this.referralCode,
    required this.referralCount,
    required this.sparksEarned,
    required this.history,
  });
}

/// Referral history item DTO
class ReferralHistoryDto {
  final String id;
  final String referredUserId;
  final String? referredUserName;
  final int sparksAwarded;
  final DateTime createdAt;

  ReferralHistoryDto({
    required this.id,
    required this.referredUserId,
    this.referredUserName,
    required this.sparksAwarded,
    required this.createdAt,
  });
}
