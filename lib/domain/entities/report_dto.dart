/// Report type enumeration
enum ReportType {
  user,
  content;

  String get value {
    switch (this) {
      case ReportType.user:
        return 'user';
      case ReportType.content:
        return 'content';
    }
  }
}

/// Content type for reporting
enum ReportContentType {
  thought,
  comment,
  message;

  String get value {
    switch (this) {
      case ReportContentType.thought:
        return 'thought';
      case ReportContentType.comment:
        return 'comment';
      case ReportContentType.message:
        return 'message';
    }
  }

  static ReportContentType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'thought':
        return ReportContentType.thought;
      case 'comment':
        return ReportContentType.comment;
      case 'message':
        return ReportContentType.message;
      default:
        return ReportContentType.thought;
    }
  }
}

/// User report DTO
class UserReportDto {
  final String userId;
  final String reason;
  final String? additionalInfo;

  UserReportDto({
    required this.userId,
    required this.reason,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'reason': reason,
      if (additionalInfo != null) 'additionalInfo': additionalInfo,
    };
  }
}

/// Content report DTO
class ContentReportDto {
  final ReportContentType contentType;
  final String contentId;
  final String reason;
  final String? additionalInfo;

  ContentReportDto({
    required this.contentType,
    required this.contentId,
    required this.reason,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'contentType': contentType.value,
      'contentId': contentId,
      'reason': reason,
      if (additionalInfo != null) 'additionalInfo': additionalInfo,
    };
  }
}
