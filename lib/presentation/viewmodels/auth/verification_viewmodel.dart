import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/auth/auth_repository_providers.dart';
import 'package:metal/domain/usecases/verification_usecase.dart';
import 'package:metal/presentation/viewmodels/base_viewmodel.dart';

/// Verification ViewModel
/// Manages email verification state
class VerificationViewModel extends BaseViewModel<void> {
  final SendVerificationCodeUseCase sendCodeUseCase;
  final VerifyCodeUseCase verifyCodeUseCase;

  Timer? _timer;
  int _remainingSeconds = 0;

  VerificationViewModel({
    required this.sendCodeUseCase,
    required this.verifyCodeUseCase,
  });

  int get remainingSeconds => _remainingSeconds;
  bool get canResend => _remainingSeconds == 0;

  /// Send verification code to email
  Future<void> sendCode(String email) async {
    setLoading();

    final result = await sendCodeUseCase(email);

    if (result.isSuccess) {
      _startResendTimer();
      setSuccess(null, action: {'type': 'code_sent'});
    } else {
      setError(result.errorMessage ?? 'Failed to send verification code');
    }
  }

  /// Verify the OTP code
  Future<void> verifyCode(String email, String code) async {
    setLoading();

    final result = await verifyCodeUseCase(
      VerifyCodeParams(email: email, code: code),
    );

    if (result.isSuccess) {
      _stopTimer();
      setSuccess(null, action: {'type': 'verified'});
    } else {
      setError(result.errorMessage ?? 'Invalid verification code');
    }
  }

  void _startResendTimer() {
    _remainingSeconds = 120; // 2 minutes to match backend cooldown
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        // Trigger state update
        state = BaseState.success(null, action: {
          'type': 'timer_tick',
          'remaining': _remainingSeconds,
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _remainingSeconds = 0;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

/// Send Verification Code Use Case Provider
final sendVerificationCodeUseCaseProvider =
    Provider<SendVerificationCodeUseCase>((ref) {
  return SendVerificationCodeUseCase(ref.read(authRepositoryProvider));
});

/// Verify Code Use Case Provider
final verifyCodeUseCaseProvider = Provider<VerifyCodeUseCase>((ref) {
  return VerifyCodeUseCase(ref.read(authRepositoryProvider));
});

/// Verification ViewModel Provider
final verificationViewModelProvider =
    StateNotifierProvider<VerificationViewModel, BaseState<void>>((ref) {
  return VerificationViewModel(
    sendCodeUseCase: ref.read(sendVerificationCodeUseCaseProvider),
    verifyCodeUseCase: ref.read(verifyCodeUseCaseProvider),
  );
});
