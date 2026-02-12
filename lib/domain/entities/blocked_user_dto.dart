import 'package:metal/domain/entities/base_entity.dart';

/// Blocked user domain entity (DTO)
class BlockedUserDto extends BaseEntity {
  final String id;
  final String userId;
  final String? username;
  final String? fullname;
  final String? profilePhoto;
  final String? reason;
  final DateTime blockedAt;

  const BlockedUserDto({
    required this.id,
    required this.userId,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.reason,
    required this.blockedAt,
  });

  BlockedUserDto copyWith({
    String? id,
    String? userId,
    String? username,
    String? fullname,
    String? profilePhoto,
    String? reason,
    DateTime? blockedAt,
  }) {
    return BlockedUserDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      reason: reason ?? this.reason,
      blockedAt: blockedAt ?? this.blockedAt,
    );
  }
}

/// Blocked users list response DTO
class BlockedUsersResponseDto extends BaseEntity {
  final List<BlockedUserDto> blockedUsers;
  final bool hasMore;
  final int? currentPage;
  final int? totalPages;

  const BlockedUsersResponseDto({
    required this.blockedUsers,
    required this.hasMore,
    this.currentPage,
    this.totalPages,
  });
}
