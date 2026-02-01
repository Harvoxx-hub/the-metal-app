import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/feedback/feedback_repository_providers.dart';
import 'package:metal/domain/entities/feedback_dto.dart';

/// State for feedback submission
class FeedbackState {
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;
  final String? successMessage;

  FeedbackState({
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
    this.successMessage,
  });

  FeedbackState copyWith({
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
    String? successMessage,
  }) {
    return FeedbackState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  factory FeedbackState.initial() => FeedbackState();
}

/// ViewModel for feedback submission
class FeedbackViewModel extends StateNotifier<FeedbackState> {
  final Ref _ref;

  FeedbackViewModel(this._ref) : super(FeedbackState.initial());

  /// Submit feedback (legacy)
  Future<bool> submitFeedback({
    required FeedbackType type,
    required String message,
    String? email,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final repository = _ref.read(feedbackRepositoryProvider);
      final feedback = FeedbackSubmissionDto(
        type: type,
        message: message,
        email: email,
      );

      final result = await repository.submitFeedback(feedback: feedback);

      if (result.isSuccess) {
        state = state.copyWith(
          isSubmitting: false,
          isSubmitted: true,
          successMessage: 'Thank you for your feedback!',
        );
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: result.errorMessage ?? 'Failed to submit feedback',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit feedback: $e',
      );
      return false;
    }
  }

  /// Submit app review feedback (improvement text and/or star rating)
  Future<bool> submitReviewFeedback({
    String? improvementFeedback,
    int? appStoreRating,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final repository = _ref.read(feedbackRepositoryProvider);
      final feedback = ReviewFeedbackSubmissionDto(
        improvementFeedback: improvementFeedback,
        appStoreRating: appStoreRating,
      );

      final result = await repository.submitReviewFeedback(feedback: feedback);

      if (result.isSuccess) {
        state = state.copyWith(
          isSubmitting: false,
          isSubmitted: true,
          successMessage: 'Thank you for your feedback!',
        );
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: result.errorMessage ?? 'Failed to submit feedback',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit feedback: $e',
      );
      return false;
    }
  }

  /// Reset state
  void reset() {
    state = FeedbackState.initial();
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}

/// Provider for feedback ViewModel
final feedbackViewModelProvider =
    StateNotifierProvider.autoDispose<FeedbackViewModel, FeedbackState>((ref) {
  return FeedbackViewModel(ref);
});
