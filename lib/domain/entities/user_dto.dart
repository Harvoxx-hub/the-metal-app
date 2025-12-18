import 'package:metal/domain/entities/base_entity.dart';

/// User domain entity (DTO)
/// This represents the user in the domain layer
class UserDto extends BaseEntity {
  final String id;
  final String email;
  final String? fullname;
  final String? phone;
  final String? profilePhoto;
  final String? fcmToken;
  final bool isVerified;
  final bool isActivated;
  final bool? emailVerified;
  final bool? profileUpdated;

  const UserDto({
    required this.id,
    required this.email,
    this.fullname,
    this.phone,
    this.profilePhoto,
    this.fcmToken,
    this.isVerified = false,
    this.isActivated = false,
    this.emailVerified,
    this.profileUpdated,
  });

  UserDto copyWith({
    String? id,
    String? email,
    String? fullname,
    String? phone,
    String? profilePhoto,
    String? fcmToken,
    bool? isVerified,
    bool? isActivated,
    bool? emailVerified,
    bool? profileUpdated,
  }) {
    return UserDto(
      id: id ?? this.id,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      fcmToken: fcmToken ?? this.fcmToken,
      isVerified: isVerified ?? this.isVerified,
      isActivated: isActivated ?? this.isActivated,
      emailVerified: emailVerified ?? this.emailVerified,
      profileUpdated: profileUpdated ?? this.profileUpdated,
    );
  }
}

/// Login response DTO
class LoginResponseDto extends BaseEntity {
  final String token;
  final UserDto user;
  final int expiresIn;
  final String? refreshToken;

  const LoginResponseDto({
    required this.token,
    required this.user,
    required this.expiresIn,
    this.refreshToken,
  });
}
