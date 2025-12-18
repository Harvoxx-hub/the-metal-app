import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/profile/profile_repository_providers.dart';
import 'package:metal/domain/usecases/profile_usecase.dart';

/// Get User Profile Use Case Provider
/// Used to fetch and maintain user state throughout the application
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(
    ref.read(profileRepositoryProvider),
  );
});

/// Update Profile Use Case Provider
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(
    ref.read(profileRepositoryProvider),
  );
});

/// Complete Profile Use Case Provider
final completeProfileUseCaseProvider = Provider<CompleteProfileUseCase>((ref) {
  return CompleteProfileUseCase(
    ref.read(profileRepositoryProvider),
  );
});
