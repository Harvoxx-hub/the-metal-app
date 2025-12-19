import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/feedback_remote_data_source.dart';
import 'package:metal/data/repositories/feedback/feedback_repository_abstract.dart';
import 'package:metal/domain/entities/feedback_dto.dart';

/// Repository for feedback operations
/// Implements business logic for feedback submission
class FeedbackRepository implements FeedbackRepositoryAbstract {
  final FeedbackRemoteDataSource _remoteDataSource;

  FeedbackRepository({
    required FeedbackRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<BaseState<bool>> submitFeedback({
    required FeedbackSubmissionDto feedback,
  }) async {
    try {
      await _remoteDataSource.submitFeedback(feedback: feedback);
      return BaseState.success(true);
    } catch (e) {
      return ErrorHandler.handleError<bool>(e);
    }
  }
}
