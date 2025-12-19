/// Block reason codes enum
/// Defines the predefined reasons for blocking a user
enum BlockReasonCode {
  harassment,
  spam,
  inappropriate,
  fake,
  other,
}

/// Extension for BlockReasonCode to provide display names
class BlockReasonCodeExtension {
  final BlockReasonCode reasonCode;

  BlockReasonCodeExtension(this.reasonCode);

  String get displayName {
    switch (reasonCode) {
      case BlockReasonCode.harassment:
        return 'Harassment or bullying';
      case BlockReasonCode.spam:
        return 'Spam or misleading content';
      case BlockReasonCode.inappropriate:
        return 'Inappropriate content';
      case BlockReasonCode.fake:
        return 'Fake account or impersonation';
      case BlockReasonCode.other:
        return 'Other';
    }
  }

  String get value {
    switch (reasonCode) {
      case BlockReasonCode.harassment:
        return 'harassment';
      case BlockReasonCode.spam:
        return 'spam';
      case BlockReasonCode.inappropriate:
        return 'inappropriate';
      case BlockReasonCode.fake:
        return 'fake';
      case BlockReasonCode.other:
        return 'other';
    }
  }
}
