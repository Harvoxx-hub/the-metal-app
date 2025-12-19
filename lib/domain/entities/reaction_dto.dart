import 'package:metal/domain/entities/base_entity.dart';

/// Reaction domain entity (DTO)
class ReactionDto extends BaseEntity {
  final String id;
  final String userId;
  final String thoughtId;
  final String emoji;
  final DateTime createdAt;

  const ReactionDto({
    required this.id,
    required this.userId,
    required this.thoughtId,
    required this.emoji,
    required this.createdAt,
  });

  ReactionDto copyWith({
    String? id,
    String? userId,
    String? thoughtId,
    String? emoji,
    DateTime? createdAt,
  }) {
    return ReactionDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      thoughtId: thoughtId ?? this.thoughtId,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
