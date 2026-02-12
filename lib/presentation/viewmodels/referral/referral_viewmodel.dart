import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/referral/referral_repository_providers.dart';
import 'package:metal/domain/entities/referral_dto.dart';

/// State for referral system
class ReferralState {
  final bool isLoading;
  final bool isApplying;
  final ReferralDto? referralInfo;
  final String? errorMessage;
  final String? successMessage;

  ReferralState({
    this.isLoading = false,
    this.isApplying = false,
    this.referralInfo,
    this.errorMessage,
    this.successMessage,
  });

  ReferralState copyWith({
    bool? isLoading,
    bool? isApplying,
    ReferralDto? referralInfo,
    String? errorMessage,
    String? successMessage,
  }) {
    return ReferralState(
      isLoading: isLoading ?? this.isLoading,
      isApplying: isApplying ?? this.isApplying,
      referralInfo: referralInfo ?? this.referralInfo,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  factory ReferralState.initial() => ReferralState();
}

/// ViewModel for referral system
class ReferralViewModel extends StateNotifier<ReferralState> {
  final Ref _ref;

  ReferralViewModel(this._ref) : super(ReferralState.initial());

  /// Load referral information
  Future<void> loadReferralInfo() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final repository = _ref.read(referralRepositoryProvider);
      final result = await repository.getReferralInfo();

      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          isLoading: false,
          referralInfo: result.data,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? 'Failed to load referral info',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load referral info: $e',
      );
    }
  }

  /// Apply referral code
  Future<bool> applyReferralCode(String code) async {
    state = state.copyWith(
      isApplying: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final repository = _ref.read(referralRepositoryProvider);
      final result = await repository.applyReferralCode(referralCode: code);

      if (result.isSuccess) {
        state = state.copyWith(
          isApplying: false,
          successMessage: 'Referral code applied successfully!',
        );
        // Reload referral info to get updated stats
        await loadReferralInfo();
        return true;
      } else {
        state = state.copyWith(
          isApplying: false,
          errorMessage: result.errorMessage ?? 'Failed to apply referral code',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isApplying: false,
        errorMessage: 'Failed to apply referral code: $e',
      );
      return false;
    }
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}

/// Provider for referral ViewModel
final referralViewModelProvider =
    StateNotifierProvider.autoDispose<ReferralViewModel, ReferralState>((ref) {
  final viewModel = ReferralViewModel(ref);
  viewModel.loadReferralInfo();
  return viewModel;
});
