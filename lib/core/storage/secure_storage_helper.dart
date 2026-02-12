import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Helper class for secure storage operations
/// Used for sensitive data like authentication tokens
class SecureStorageHelper {
  final FlutterSecureStorage _storage;

  SecureStorageHelper({
    AndroidOptions? androidOptions,
    IOSOptions? iosOptions,
  }) : _storage = FlutterSecureStorage(
          aOptions: androidOptions ??
              const AndroidOptions(
                encryptedSharedPreferences: true,
              ),
          iOptions: iosOptions ??
              const IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
        );

  /// Get string value
  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  /// Set string value
  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Delete value
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Delete all values
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Get all keys
  Future<List<String>> getAllKeys() async {
    final allData = await _storage.readAll();
    return allData.keys.toList();
  }
}
