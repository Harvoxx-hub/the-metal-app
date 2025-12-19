import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/feedback_dto.dart';

/// Abstract repository for feedback operations
abstract class FeedbackRepositoryAbstract {
  /// Submit user feedback
  Future<BaseState<bool>> submitFeedback({
    required FeedbackSubmissionDto feedback,
  });
}
