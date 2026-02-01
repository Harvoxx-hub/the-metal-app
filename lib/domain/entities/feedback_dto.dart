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

/// Feedback submission request DTO (legacy - bug/feature/general)
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
      'subject': _subjectFromType,
      'description': message,
    };
  }

  String get _subjectFromType {
    switch (type) {
      case FeedbackType.bug:
        return 'Bug Report';
      case FeedbackType.feature:
        return 'Feature Request';
      case FeedbackType.general:
        return 'General Feedback';
    }
  }
}

/// App review feedback submission DTO
/// Maps to backend type/subject/description format
class ReviewFeedbackSubmissionDto {
  final String? improvementFeedback;
  final int? appStoreRating;

  ReviewFeedbackSubmissionDto({
    this.improvementFeedback,
    this.appStoreRating,
  });

  Map<String, dynamic> toJson() {
    final description = _buildDescription();
    return {
      'type': 'general',
      'subject': 'App review',
      'description': description,
    };
  }

  String _buildDescription() {
    final parts = <String>[];
    if (improvementFeedback != null &&
        improvementFeedback!.trim().isNotEmpty) {
      parts.add(improvementFeedback!.trim());
    }
    if (appStoreRating != null && appStoreRating! > 0) {
      parts.add('App store rating: $appStoreRating/5 stars');
    }
    var result = parts.isEmpty
        ? 'No additional feedback provided'
        : parts.join('. ');
    // Backend requires min 10 chars
    if (result.length < 10) {
      result = '$result (App review)';
    }
    return result;
  }
}
