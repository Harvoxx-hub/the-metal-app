import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metal/core/services/api.service.dart';

enum LoginState { loggedIn, loggedOut }

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;

  SharedPreferences? _prefs;

  AuthManager._internal() {
    _load();
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> ensureInitialized() async {
    await _instance._load();
  }

  static Future<void> saveAccessToken(String accessToken) async {
    await _instance._prefs?.setString('access_token', accessToken);
  }

  static Future<String?> getAccessToken() async {
    return _instance._prefs?.getString('access_token');
  }

  static Future<void> deleteAccessToken() async {
    await _instance._prefs?.remove('access_token');
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    await _instance._prefs?.setString('refresh_token', refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    return _instance._prefs?.getString('refresh_token');
  }

  static Future<String> refreshToken() async {
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

  static Future<void> deleteRefreshToken() async {
    await _instance._prefs?.remove('refresh_token');
  }

  static Future<void> saveLoginState(LoginState loginState) async {
    await _instance._prefs?.setString('login_state', loginState.toString());
  }

  static Future<LoginState?> getLoginState() async {
    final loginStateString = _instance._prefs?.getString('login_state');
    return loginStateString != null
        ? LoginState.values.firstWhere((e) => e.toString() == loginStateString)
        : null;
  }

  static Future<void> deleteLoginState() async {
    await _instance._prefs?.remove('login_state');
  }
}

final authManagerProvider = Provider((ref) {
  final authManager = AuthManager();

  return authManager;
});
