import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/auth/auth_repository_abstract.dart';
import 'package:metal/data/repositories/auth/auth_repository_providers.dart';
import 'package:metal/presentation/viewmodels/base_viewmodel.dart';

/// Forgot password step
enum ForgotPasswordStep { email, otp, newPassword }

/// Forgot Password ViewModel
class ForgotPasswordViewModel extends BaseViewModel<void> {
  final AuthRepositoryAbstract repository;

  ForgotPasswordViewModel({required this.repository});

  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;
  String _email = '';
  Timer? _timer;
  int _remainingSeconds = 0;

  ForgotPasswordStep get currentStep => _currentStep;
  String get email => _email;
  int get remainingSeconds => _remainingSeconds;
  bool get canResend => _remainingSeconds == 0;

  /// Send OTP to email
  Future<void> sendOtp(String email) async {
    _email = email;
    setLoading();

    final result = await repository.sendVerificationCode(email);

    if (result.isSuccess) {
      _currentStep = ForgotPasswordStep.otp;
      _startResendTimer();
      setSuccess(null, action: {'type': 'otp_sent'});
    } else {
      setError(result.errorMessage ?? 'Failed to send verification code');
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (_email.isEmpty) return;
    setLoading();

    final result = await repository.sendVerificationCode(_email);

    if (result.isSuccess) {
      _startResendTimer();
      setSuccess(null, action: {'type': 'otp_resent'});
    } else {
      setError(result.errorMessage ?? 'Failed to resend code');
    }
  }

  /// Verify OTP and move to password step
  Future<void> verifyOtp(String code) async {
    if (_email.isEmpty) return;
    setLoading();

    // We don't verify here - we verify when resetting password
    // Just move to password step
    _currentStep = ForgotPasswordStep.newPassword;
    _stopTimer();
    // Store the code temporarily
    setSuccess(null, action: {'type': 'otp_verified', 'code': code});
  }

  /// Reset password
  Future<void> resetPassword(String code, String newPassword) async {
    if (_email.isEmpty) return;
    setLoading();

    final result = await repository.resetPassword(
      email: _email,
      code: code,
      newPassword: newPassword,
    );

    if (result.isSuccess) {
      setSuccess(null, action: {'type': 'password_reset'});
    } else {
      setError(result.errorMessage ?? 'Password reset failed');
    }
  }

  /// Go back to previous step
  void goBack() {
    switch (_currentStep) {
      case ForgotPasswordStep.otp:
        _currentStep = ForgotPasswordStep.email;
        _stopTimer();
        break;
      case ForgotPasswordStep.newPassword:
        _currentStep = ForgotPasswordStep.otp;
        break;
      case ForgotPasswordStep.email:
        break;
    }
    reset();
  }

  void _startResendTimer() {
    _remainingSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
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

/// Forgot Password ViewModel Provider
final forgotPasswordViewModelProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordViewModel, BaseState<void>>(
        (ref) {
  return ForgotPasswordViewModel(
    repository: ref.read(authRepositoryProvider),
  );
});

