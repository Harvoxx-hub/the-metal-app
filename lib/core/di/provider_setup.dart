import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/network/api_interceptor.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';
import 'package:metal/core/storage/shared_prefs_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Core providers for dependency injection
/// These are the foundation providers that other providers depend on

/// SharedPreferences provider
/// This is initialized eagerly in main() before the app starts
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This should never be null as it's initialized in main()
  throw UnimplementedError(
    'SharedPreferences must be initialized in main() and provided via override',
  );
});

/// SharedPrefsHelper provider
final sharedPrefsHelperProvider = Provider<SharedPrefsHelper>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsHelper(prefs);
});

/// SecureStorageHelper provider
final secureStorageHelperProvider = Provider<SecureStorageHelper>((ref) {
  return SecureStorageHelper();
});

/// ApiInterceptor provider
/// Note: authRemoteDataSource is injected lazily to avoid circular dependency
final apiInterceptorProvider = Provider<ApiInterceptor>((ref) {
  final interceptor = ApiInterceptor(
    sharedPrefs: ref.watch(sharedPrefsHelperProvider),
    secureStorage: ref.watch(secureStorageHelperProvider),
  );
  // Inject authRemoteDataSource after creation to avoid circular dependency
  // This will be set up in a separate initialization step if needed
  return interceptor;
});

/// DioClient provider - Core HTTP client
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    interceptor: ref.watch(apiInterceptorProvider),
  );
});
