import 'package:metal/domain/entities/spark_dto.dart';

/// Spark response model from API
class SparkModel {
  final int balance;
  final List<SparkTransactionModel> transactions;
  final PaginationModel? pagination;

  SparkModel({
    required this.balance,
    required this.transactions,
    this.pagination,
  });

  factory SparkModel.fromJson(Map<String, dynamic> json) {
    return SparkModel(
      balance: json['balance'] as int? ?? 0,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((t) =>
                  SparkTransactionModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to domain DTO
  SparkDto toDomain() {
    return SparkDto(
      balance: balance,
      transactions: transactions.map((t) => t.toDomain()).toList(),
      hasMore: pagination?.hasMore ?? false,
      currentPage: pagination?.currentPage,
    );
  }
}

/// Spark transaction model
class SparkTransactionModel {
  final String id;
  final int amount;
  final String type;
  final String? senderId;
  final String? senderName;
  final String? recipientId;
  final String? recipientName;
  final String? message;
  final String createdAt;

  SparkTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    this.senderId,
    this.senderName,
    this.recipientId,
    this.recipientName,
    this.message,
    required this.createdAt,
  });

  factory SparkTransactionModel.fromJson(Map<String, dynamic> json) {
    return SparkTransactionModel(
      id: json['id'] as String,
      amount: json['amount'] as int,
      type: json['type'] as String,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      recipientId: json['recipientId'] as String?,
      recipientName: json['recipientName'] as String?,
      message: json['message'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Convert to domain DTO
  SparkTransactionDto toDomain() {
    return SparkTransactionDto(
      id: id,
      amount: amount,
      type: _parseTransactionType(type),
      senderId: senderId,
      senderName: senderName,
      recipientId: recipientId,
      recipientName: recipientName,
      message: message,
      timestamp: DateTime.parse(createdAt),
    );
  }

  SparkTransactionType _parseTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'earned':
      case 'awarded': // Backend uses 'awarded' for referral/spark rewards
        return SparkTransactionType.earned;
      case 'sent':
        return SparkTransactionType.sent;
      case 'received':
        return SparkTransactionType.received;
      case 'purchased':
        return SparkTransactionType.purchased;
      case 'spent':
        return SparkTransactionType.spent;
      default:
        return SparkTransactionType.earned;
    }
  }
}

/// Pagination model
class PaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      totalItems: json['totalItems'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

/// Send spark response model
class SendSparkResponseModel {
  final int newBalance;
  final SparkTransactionModel transaction;

  SendSparkResponseModel({
    required this.newBalance,
    required this.transaction,
  });

  factory SendSparkResponseModel.fromJson(Map<String, dynamic> json) {
    final transactionJson = json['transaction'];
    final SparkTransactionModel transaction;
    if (transactionJson != null && transactionJson is Map<String, dynamic>) {
      transaction = SparkTransactionModel.fromJson(transactionJson);
    } else {
      // Backend may return only newBalance, amount, recipientId, transactionId
      transaction = SparkTransactionModel(
        id: json['transactionId'] as String? ?? '',
        amount: (json['amount'] as int?) ?? 0,
        type: 'sent',
        senderId: null,
        senderName: null,
        recipientId: json['recipientId'] as String?,
        recipientName: null,
        message: json['message'] as String?,
        createdAt: DateTime.now().toIso8601String(),
      );
    }
    return SendSparkResponseModel(
      newBalance: json['newBalance'] as int? ?? 0,
      transaction: transaction,
    );
  }
}
