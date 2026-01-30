/// Google Maps / Places API configuration.
/// Set the API key directly below (replace with your key), or via
/// --dart-define=GOOGLE_MAPS_API_KEY=your_key. For the map to load on device,
/// also set: Android = android/local.properties (GOOGLE_MAPS_API_KEY=...),
/// iOS = ios/Runner/Info.plist (GOOGLE_MAPS_API_KEY key).
class MapConfig {
  MapConfig._();

  /// Paste your Google Maps API key here. Also add the same key to
  /// android/local.properties and ios/Runner/Info.plist for the map widget.
  static const String _apiKeyDirect = 'YOUR_GOOGLE_MAPS_API_KEY';

  /// Google Maps API key (direct or from --dart-define).
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: _apiKeyDirect);

  static bool get hasGoogleMapsKey => googleMapsApiKey.isNotEmpty &&
      googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY';
}
