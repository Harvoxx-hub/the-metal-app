import 'package:metal/data/models/spark_model.dart';
import 'package:metal/domain/entities/blocked_user_dto.dart';

/// Blocked user response model from API
class BlockedUsersResponseModel {
  final List<BlockedUserModel> blockedUsers;
  final PaginationModel? pagination;

  BlockedUsersResponseModel({
    required this.blockedUsers,
    this.pagination,
  });

  factory BlockedUsersResponseModel.fromJson(Map<String, dynamic> json) {
    return BlockedUsersResponseModel(
      blockedUsers: (json['blockedUsers'] as List<dynamic>?)
              ?.map((user) => BlockedUserModel.fromJson(user as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to domain DTO
  BlockedUsersResponseDto toDomain() {
    return BlockedUsersResponseDto(
      blockedUsers: blockedUsers.map((user) => user.toDomain()).toList(),
      hasMore: pagination?.hasMore ?? false,
      currentPage: pagination?.currentPage,
      totalPages: pagination?.totalPages,
    );
  }
}

/// Blocked user model
class BlockedUserModel {
  final String id;
  final String userId;
  final String? username;
  final String? fullname;
  final String? profilePhoto;
  final String? reason;
  final String blockedAt;

  BlockedUserModel({
    required this.id,
    required this.userId,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.reason,
    required this.blockedAt,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) {
    return BlockedUserModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String?,
      fullname: json['fullname'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      reason: json['reason'] as String?,
      blockedAt: json['blockedAt'] as String,
    );
  }

  /// Convert to domain DTO
  BlockedUserDto toDomain() {
    return BlockedUserDto(
      id: id,
      userId: userId,
      username: username,
      fullname: fullname,
      profilePhoto: profilePhoto,
      reason: reason,
      blockedAt: DateTime.parse(blockedAt),
    );
  }
}
