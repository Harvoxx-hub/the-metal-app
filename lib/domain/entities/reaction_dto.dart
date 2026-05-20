import 'package:metal/domain/entities/base_entity.dart';

/// Reaction domain entity (DTO)
class ReactionDto extends BaseEntity {
  final String id;
  final String userId;
  final String thoughtId;
  final String emoji;
  final DateTime createdAt;
  /// Denormalized from the reaction document — available even if the user
  /// profile can no longer be fetched (deleted account, network error).
  final String? username;
  final String? metalId;

  const ReactionDto({
    required this.id,
    required this.userId,
    required this.thoughtId,
    required this.emoji,
    required this.createdAt,
    this.username,
    this.metalId,
  });

  ReactionDto copyWith({
    String? id,
    String? userId,
    String? thoughtId,
    String? emoji,
    DateTime? createdAt,
    String? username,
    String? metalId,
  }) {
    return ReactionDto(
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
