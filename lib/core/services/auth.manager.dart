import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:metal/core/services/api.service.dart';

enum LoginState { loggedIn, loggedOut }

class AuthManager {
  late final FlutterSecureStorage _storage;

  AuthManager() {
    _storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'access_token');
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  //refresh token
  Future<String> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }

    final response = await ApiService().post(
      'https://metal-server.vercel.app/api/v1/auth/refresh-token',
      body: {
        'refreshtoken': refreshToken,
      },
    );

    final data = response.data;
    await saveAccessToken(data['access_token']);
    return data['access_token'];

    return '';
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  Future<void> saveLoginState(LoginState loginState) async {
    await _storage.write(key: 'login_state', value: loginState.toString());
  }

  Future<LoginState?> getLoginState() async {
    final loginStateString = await _storage.read(key: 'login_state');

    return loginStateString != null
        ? LoginState.values.firstWhere((e) => e.toString() == loginStateString)
        : null;
  }

  Future<void> deleteLoginState() async {
    await _storage.delete(key: 'login_state');
  }
}

final authManagerProvider = Provider((ref) {
  return AuthManager();
});
