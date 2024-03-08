import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metal/core/services/api.service.dart';

enum LoginState { loggedIn, loggedOut }

class AuthManager {
  late final SharedPreferences _prefs;

  AuthManager() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _prefs.setString('access_token', accessToken);
  }

  Future<String?> getAccessToken() async {
    return _prefs.getString('access_token');
  }

  Future<void> deleteAccessToken() async {
    await _prefs.remove('access_token');
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _prefs.setString('refresh_token', refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return _prefs.getString('refresh_token');
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
  }

  Future<void> deleteRefreshToken() async {
    await _prefs.remove('refresh_token');
  }

  Future<void> saveLoginState(LoginState loginState) async {
    await _prefs.setString('login_state', loginState.toString());
  }

  Future<LoginState?> getLoginState() async {
    final loginStateString = _prefs.getString('login_state');

    return loginStateString != null
        ? LoginState.values.firstWhere((e) => e.toString() == loginStateString)
        : null;
  }

  Future<void> deleteLoginState() async {
    await _prefs.remove('login_state');
  }
}

final authManagerProvider = Provider((ref) {
  return AuthManager();
});
