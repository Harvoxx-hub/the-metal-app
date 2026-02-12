/// Global application constants
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  /// API base URL (without /api/v1 suffix)
  static const String apiBaseUrl =
      'https://web-production-62f2a.up.railway.app';

  /// Full API URL with version
  static const String apiUrl = '$apiBaseUrl/api/v1';

  /// App name
  static const String appName = 'Metal';
}
