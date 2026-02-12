import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/verification/verification_repository_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';

/// State for work email verification
class WorkEmailVerificationState {
  final bool isLoading;
  final bool codeSent;
  final bool isVerified;
  final String? errorMessage;
  final String? successMessage;
  final String? workEmail;

  WorkEmailVerificationState({
    this.isLoading = false,
    this.codeSent = false,
    this.isVerified = false,
    this.errorMessage,
    this.successMessage,
    this.workEmail,
  });

  WorkEmailVerificationState copyWith({
    bool? isLoading,
    bool? codeSent,
    bool? isVerified,
    String? errorMessage,
    String? successMessage,
    String? workEmail,
  }) {
    return WorkEmailVerificationState(
      isLoading: isLoading ?? this.isLoading,
      codeSent: codeSent ?? this.codeSent,
      isVerified: isVerified ?? this.isVerified,
      errorMessage: errorMessage,
      successMessage: successMessage,
      workEmail: workEmail ?? this.workEmail,
    );
  }

  factory WorkEmailVerificationState.initial() => WorkEmailVerificationState();
}

/// ViewModel for work email verification
class WorkEmailVerificationViewModel
    extends StateNotifier<WorkEmailVerificationState> {
  final Ref _ref;

  WorkEmailVerificationViewModel(this._ref)
      : super(WorkEmailVerificationState.initial());

  /// Request verification code for work email
  Future<bool> requestVerification({required String workEmail}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      workEmail: workEmail,
    );

    try {
      final repository = _ref.read(verificationRepositoryProvider);
      final result = await repository.requestWorkEmailVerification(
        workEmail: workEmail,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          codeSent: true,
          successMessage: 'Verification code sent to $workEmail',
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? 'Failed to send code',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send code: $e',
      );
      return false;
    }
  }

  /// Verify the code sent to work email
  Future<bool> verifyCode({required String code}) async {
    if (state.workEmail == null) {
      state = state.copyWith(
        errorMessage: 'Work email not found. Please request code first.',
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final repository = _ref.read(verificationRepositoryProvider);
      final result = await repository.verifyWorkEmailCode(
        workEmail: state.workEmail!,
        code: code,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          isVerified: true,
          successMessage: 'Work email verified successfully!',
        );
        await _ref.read(userStateProvider.notifier).fetchAndSetUser();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? 'Invalid verification code',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Verification failed: $e',
      );
      return false;
    }
  }

  /// Reset state
  void reset() {
    state = WorkEmailVerificationState.initial();
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}

/// Provider for work email verification ViewModel
final workEmailVerificationViewModelProvider = StateNotifierProvider<
    WorkEmailVerificationViewModel, WorkEmailVerificationState>((ref) {
  return WorkEmailVerificationViewModel(ref);
});
