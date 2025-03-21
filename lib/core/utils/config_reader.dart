abstract class ConfigReader {
  static Map<String, dynamic>? _config;
  static bool _isDevMode = false;
  static Future<void> initialize(String env) async {
    _isDevMode = env == "dev";
  }

  static bool isDevMode() {
    return _isDevMode;
  }

  static String getBaseUrl() {
    return _config!['baseUrl'] as String;
  }
}
