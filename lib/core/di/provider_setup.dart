import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';
import 'package:metal/core/storage/shared_prefs_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gate that completes when dashboard startup tasks (including location attempt) finish.
/// HomeView awaits this before running its own location/discovery flow to avoid races.
class StartupGateNotifier extends StateNotifier<Completer<void>?> {
  StartupGateNotifier() : super(null);

  /// Run [run] and complete the gate when done. Only runs once per app session.
  Future<void> runAfterGate(Future<void> Function() run) async {
    if (state != null) return;
    final completer = Completer<void>();
    state = completer;
    try {
      await run();
    } catch (_) {}
    if (!completer.isCompleted) completer.complete();
  }
}

final startupGateProvider =
    StateNotifierProvider<StartupGateNotifier, Completer<void>?>((ref) {
  return StartupGateNotifier();
});

/// Current dashboard tab index (0 = Home/Discovery). Used by HomeView to re-check location when tab becomes visible.
final currentDashboardTabIndexProvider = StateProvider<int>((ref) => 0);

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

/// DioClient provider - Core HTTP client
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    secureStorage: ref.watch(secureStorageHelperProvider),
    sharedPrefs: ref.watch(sharedPrefsHelperProvider),
  );
});
