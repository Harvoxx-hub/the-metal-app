import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/profile/profile_repository.dart';
import 'package:metal/data/repositories/profile/profile_repository_providers.dart';

/// Delete Account State
class DeleteAccountState {
  final bool isDeleting;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;

  const DeleteAccountState({
    this.isDeleting = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
  });

  /// Initial state
  factory DeleteAccountState.initial() => const DeleteAccountState();

  /// Deleting state
  factory DeleteAccountState.deleting() => const DeleteAccountState(
        isDeleting: true,
      );

  /// Success state
  factory DeleteAccountState.success() => const DeleteAccountState(
        isSuccess: true,
      );

  /// Error state
  factory DeleteAccountState.error(String message) => DeleteAccountState(
        isError: true,
        errorMessage: message,
      );

  /// Copy with
  DeleteAccountState copyWith({
    bool? isDeleting,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
  }) {
    return DeleteAccountState(
      isDeleting: isDeleting ?? this.isDeleting,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Delete Account ViewModel
/// Handles account deletion operations
class DeleteAccountViewModel extends StateNotifier<DeleteAccountState> {
  final ProfileRepository _repository;

  DeleteAccountViewModel({
    required ProfileRepository repository,
  })  : _repository = repository,
        super(DeleteAccountState.initial());

  /// Delete user account with password confirmation
  Future<bool> deleteAccount({required String password}) async {
    if (state.isDeleting) return false;

    state = DeleteAccountState.deleting();

    final result = await _repository.deleteAccount(password: password);

    if (mounted) {
      if (result.isSuccess) {
        state = DeleteAccountState.success();
        return true;
      } else {
        state = DeleteAccountState.error(
          result.errorMessage ?? 'Failed to delete account',
        );
        return false;
      }
    }

    return false;
  }

  /// Reset state (e.g., after showing error message)
  void resetState() {
    if (mounted) {
      state = DeleteAccountState.initial();
    }
  }
}

/// Delete Account ViewModel Provider
final deleteAccountViewModelProvider = StateNotifierProvider.autoDispose<
    DeleteAccountViewModel, DeleteAccountState>((ref) {
  final repository =
      ref.watch(profileRepositoryProvider) as ProfileRepository;
  return DeleteAccountViewModel(repository: repository);
});
