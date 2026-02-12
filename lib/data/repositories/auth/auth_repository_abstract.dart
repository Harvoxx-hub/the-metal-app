import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/base_repository.dart';
import 'package:metal/domain/entities/user_dto.dart';

/// Abstract repository interface for authentication
/// This defines the contract that all auth repositories must implement
abstract class AuthRepositoryAbstract extends BaseRepository {
  /// Login with email and password
  Future<BaseState<LoginResponseDto>> login({
    required String email,
    required String password,
  });

  /// Signup with user details
  Future<BaseState<LoginResponseDto>> signup({
    required String email,
    required String password,
    required String phoneNumber,
    String? referralCode,
    String? fcmToken,
  });

  /// Logout user
  Future<BaseState<void>> logout();

  /// Send verification code to email
  Future<BaseState<void>> sendVerificationCode(String email);

  /// Verify OTP code
  Future<BaseState<void>> verifyCode({
    required String email,
    required String code,
  });

  /// Reset password with OTP
  Future<BaseState<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
