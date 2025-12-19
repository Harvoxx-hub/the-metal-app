/// Feedback type enumeration
enum FeedbackType {
  bug,
  feature,
  general;

  String get value {
    switch (this) {
      case FeedbackType.bug:
        return 'bug';
      case FeedbackType.feature:
        return 'feature';
      case FeedbackType.general:
        return 'general';
    }
  }

  static FeedbackType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bug':
        return FeedbackType.bug;
      case 'feature':
        return FeedbackType.feature;
      case 'general':
        return FeedbackType.general;
      default:
        return FeedbackType.general;
    }
  }
}

/// Feedback submission request DTO
class FeedbackSubmissionDto {
  final FeedbackType type;
  final String message;
  final String? email;

  FeedbackSubmissionDto({
    required this.type,
    required this.message,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'message': message,
      if (email != null) 'email': email,
    };
  }
}
