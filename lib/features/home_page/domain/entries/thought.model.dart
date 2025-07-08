import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

/// Author metadata embedded in thought documents for denormalization
/// This reduces the need to fetch user profiles separately during filtering
class AuthorMetadata {
  final String authorId;
  final String? authorName;
  final String? authorGender;
  final int? authorAge;
  final String? authorLocationName;
  final double? authorLatitude;
  final double? authorLongitude;
  final String? authorRelationshipType;
  final String? authorCommunity;
  final bool? authorIsVerified;
  final String? authorProfilePhoto;

  const AuthorMetadata({
    required this.authorId,
    this.authorName,
    this.authorGender,
    this.authorAge,
    this.authorLocationName,
    this.authorLatitude,
    this.authorLongitude,
    this.authorRelationshipType,
    this.authorCommunity,
    this.authorIsVerified,
    this.authorProfilePhoto,
  });

  factory AuthorMetadata.fromJson(Map<String, dynamic> json) {
    return AuthorMetadata(
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String?,
      authorGender: json['authorGender'] as String?,
      authorAge: json['authorAge'] as int?,
      authorLocationName: json['authorLocationName'] as String?,
      authorLatitude: json['authorLatitude'] as double?,
      authorLongitude: json['authorLongitude'] as double?,
      authorRelationshipType: json['authorRelationshipType'] as String?,
      authorCommunity: json['authorCommunity'] as String?,
      authorIsVerified: json['authorIsVerified'] as bool?,
      authorProfilePhoto: json['authorProfilePhoto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorGender': authorGender,
      'authorAge': authorAge,
      'authorLocationName': authorLocationName,
      'authorLatitude': authorLatitude,
      'authorLongitude': authorLongitude,
      'authorRelationshipType': authorRelationshipType,
      'authorCommunity': authorCommunity,
      'authorIsVerified': authorIsVerified,
      'authorProfilePhoto': authorProfilePhoto,
    };
  }

  /// Creates AuthorMetadata from UserModel
  /// This is used when creating a new thought to embed author data
  factory AuthorMetadata.fromUserModel(UserModel userModel) {
    // Calculate age safely from dob if age is not directly available
    int? calculatedAge;
    if (userModel.dob != null) {
      calculatedAge = _calculateAgeFromDob(userModel.dob);
    }
    final connectionOption =
        userModel.connectionOption!.map((e) => e).join(", ");
    final community = "";

    return AuthorMetadata(
      authorId: userModel.id ?? '',
      authorName: userModel.username ?? userModel.fullname,
      authorGender: userModel.gender,
      authorAge: calculatedAge,
      authorLocationName: userModel.location?.address ?? "",
      authorLatitude: userModel.location?.lat,
      authorLongitude: userModel.location?.lng,
      authorRelationshipType: connectionOption,
      authorCommunity: community,
      authorIsVerified: userModel.isVerified,
      authorProfilePhoto: userModel.profilePhoto,
    );
  }

  /// Calculate age from date of birth string
  /// Handles various date formats safely
  static int? _calculateAgeFromDob(String? dob) {
    if (dob == null || dob.isEmpty) return null;

    try {
      DateTime dobDate;

      // Handle MM/dd/yyyy format (e.g., "01/01/2007")
      if (dob.contains('/') && dob.split('/').length == 3) {
        final parts = dob.split('/');
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        dobDate = DateTime(year, month, day);
      }
      // Handle yyyy-MM-dd format (ISO format)
      else if (dob.contains('-') && dob.split('-').length == 3) {
        dobDate = DateTime.parse(dob);
      }
      // Handle dd/MM/yyyy format (e.g., "01/01/2007")
      else if (dob.contains('/')) {
        final parts = dob.split('/');
        if (parts.length == 3) {
          // Try MM/dd/yyyy first, then dd/MM/yyyy
          try {
            final month = int.parse(parts[0]);
            final day = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            dobDate = DateTime(year, month, day);
          } catch (e) {
            // Try dd/MM/yyyy format
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            dobDate = DateTime(year, month, day);
          }
        } else {
          return null;
        }
      }
      // Try direct parsing as fallback
      else {
        dobDate = DateTime.parse(dob);
      }

      // Calculate age
      final now = DateTime.now();
      int age = now.year - dobDate.year;

      // Adjust if birthday hasn't occurred this year
      if (now.month < dobDate.month ||
          (now.month == dobDate.month && now.day < dobDate.day)) {
        age--;
      }

      return age >= 0 ? age : null;
    } catch (e) {
      print('Error parsing date of birth "$dob": $e');
      return null; // Return null if parsing fails
    }
  }
}

class ThoughtModel {
  final String id;
  final String userId;
  final String content;
  final String createdAt;
  final bool connectionOnly;
  final AuthorMetadata? authorMetadata;

  ThoughtModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.connectionOnly = false,
    this.authorMetadata,
  });

  factory ThoughtModel.fromJson(Map<String, dynamic> json) {
    return ThoughtModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      connectionOnly: json['connectionOnly'] as bool? ?? false,
      authorMetadata: json['authorMetadata'] != null
          ? AuthorMetadata.fromJson(
              json['authorMetadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
      'connectionOnly': connectionOnly,
      'authorMetadata': authorMetadata?.toJson(),
    };
  }

  /// Creates a copy of this ThoughtModel with updated authorMetadata
  /// Useful for syncing metadata when user profile changes
  ThoughtModel copyWithAuthorMetadata(AuthorMetadata newAuthorMetadata) {
    return ThoughtModel(
      id: id,
      userId: userId,
      content: content,
      createdAt: createdAt,
      connectionOnly: connectionOnly,
      authorMetadata: newAuthorMetadata,
    );
  }
}
