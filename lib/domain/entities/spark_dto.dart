/// Spark balance and transaction data transfer object
class SparkDto {
  final int balance;
  final List<SparkTransactionDto> transactions;
  final bool hasMore;
  final int? currentPage;

  SparkDto({
    required this.balance,
    required this.transactions,
    this.hasMore = false,
    this.currentPage,
  });

  factory SparkDto.empty() {
    return SparkDto(
      balance: 0,
      transactions: [],
      hasMore: false,
    );
  }

  SparkDto copyWith({
    int? balance,
    List<SparkTransactionDto>? transactions,
    bool? hasMore,
    int? currentPage,
  }) {
    return SparkDto(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Individual spark transaction DTO
class SparkTransactionDto {
  final String id;
  final int amount;
  final SparkTransactionType type;
  final String? senderId;
  final String? senderName;
  final String? recipientId;
  final String? recipientName;
  final String? message;
  final DateTime timestamp;

  SparkTransactionDto({
    required this.id,
    required this.amount,
    required this.type,
    this.senderId,
    this.senderName,
    this.recipientId,
    this.recipientName,
    this.message,
    required this.timestamp,
  });
}

/// Spark transaction types
enum SparkTransactionType {
  earned,    // From referrals, rewards, etc.
  sent,      // Sent to another user
  received,  // Received from another user
  purchased, // Purchased via in-app purchase
  spent,     // Spent on features/boosts
}
