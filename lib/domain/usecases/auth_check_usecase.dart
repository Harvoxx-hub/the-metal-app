import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';
import 'package:metal/core/storage/shared_prefs_helper.dart';
import 'package:metal/data/repositories/profile/profile_repository_abstract.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/usecases/base_usecase.dart';

/// Use case to check if user is authenticated
/// Checks for stored token and fetches user profile if authenticated
class AuthCheckUseCase implements BaseUseCaseNoParams<UserDto?> {
  final SecureStorageHelper secureStorage;
  final SharedPrefsHelper sharedPrefs;
  final ProfileRepositoryAbstract profileRepository;

  AuthCheckUseCase({
    required this.secureStorage,
    required this.sharedPrefs,
    required this.profileRepository,
  });

  @override
  Future<BaseState<UserDto?>> call() async {
    try {
      // Check if auth token exists
      final token = await secureStorage.getString('auth_token');

      if (token == null || token.isEmpty) {
        // No token found, user is not authenticated
        return BaseState.success(null);
      }

      // Token exists - fetch user profile to validate token and get user data
      try {
        final profileResult = await profileRepository.getUserProfile();
        if (profileResult.isSuccess && profileResult.data != null) {
          return BaseState.success(profileResult.data);
        } else {
          // Token exists but profile fetch failed - token might be invalid
          // Clear token and return null
          await secureStorage.delete('auth_token');
          await secureStorage.delete('refresh_token');
          return BaseState.success(null);
        }
      } catch (e) {
        // Profile fetch failed - clear tokens and return null
        await secureStorage.delete('auth_token');
        await secureStorage.delete('refresh_token');
        return BaseState.success(null);
      }
    } catch (e) {
      return BaseState.error('Failed to check authentication: ${e.toString()}');
    }
  }

  /// Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    return sharedPrefs.getBool('hasSeenOnboarding') ?? false;
  }

  /// Mark onboarding as seen
  Future<void> markOnboardingSeen() async {
    await sharedPrefs.setBool('hasSeenOnboarding', true);
  }
}
