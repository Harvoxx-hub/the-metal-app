import 'package:metal/domain/entities/reaction_dto.dart';

/// Reaction response model from API
class ReactionModel {
  final String id;
  final String userId;
  final String thoughtId;
  final String emoji;
  final String createdAt;
  final String? username;
  final String? metalId;

  ReactionModel({
    required this.id,
    required this.userId,
    required this.thoughtId,
    required this.emoji,
    required this.createdAt,
    this.username,
    this.metalId,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      thoughtId: json['thoughtId'] as String,
      emoji: json['emoji'] as String,
      createdAt: json['createdAt'] as String,
      username: json['username'] as String?,
      metalId: json['metalId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'thoughtId': thoughtId,
      'emoji': emoji,
      'createdAt': createdAt,
      if (username != null) 'username': username,
      if (metalId != null) 'metalId': metalId,
    };
  }

  /// Convert to domain DTO
  ReactionDto toDomain() {
    return ReactionDto(
      id: id,
      userId: userId,
      thoughtId: thoughtId,
      emoji: emoji,
      createdAt: DateTime.parse(createdAt),
      username: username,
      metalId: metalId,
    );
  }

  ReactionModel copyWith({
    String? id,
    String? userId,
    String? thoughtId,
    String? emoji,
    String? createdAt,
    String? username,
    String? metalId,
  }) {
    return ReactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      thoughtId: thoughtId ?? this.thoughtId,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      metalId: metalId ?? this.metalId,
    );
  }
}
