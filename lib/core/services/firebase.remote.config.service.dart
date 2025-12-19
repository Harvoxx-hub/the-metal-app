import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:metal/core/utils/constant/firebase.remote.config.key.dart';
 
class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._()
      : _remoteConfig = FirebaseRemoteConfig.instance;

  static FirebaseRemoteConfigService? _instance;
  factory FirebaseRemoteConfigService() =>
      _instance ??= FirebaseRemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig;
  FirebaseRemoteConfig get remoteConfig => _remoteConfig;

  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);

  Future<void> initialize() async {
    await _setConfigSettings();
    await _setDefaults();
    await fetchAndActivate();
  }

  Future<void> _setConfigSettings() async => _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(seconds: 2),
        ),
      );

  Future<void> _setDefaults() async => _remoteConfig.setDefaults(
        const {
          FirebaseRemoteConfigKeys.metalProperties: '',
          FirebaseRemoteConfigKeys.daysRequiredToUnMelt: 0,
          FirebaseRemoteConfigKeys.latest_version: "",
          FirebaseRemoteConfigKeys.rules: "",
        },
      );

  Future<void> fetchAndActivate() async {
    bool updated = await _remoteConfig.fetchAndActivate();

    if (updated) {
      debugPrint('The config has been updated.');
    } else {
      debugPrint('The config is not updated..');
    }
  }

  // Helper methods to get specific values
  String getLatestVersion() =>
      getString(FirebaseRemoteConfigKeys.latest_version);
  Map<String, dynamic> getMetalProperties() =>
 jsonDecode(
          getString(FirebaseRemoteConfigKeys.metalProperties)) ??
      {};
  int getDaysRequiredToUnMelt() =>
      getInt(FirebaseRemoteConfigKeys.daysRequiredToUnMelt);
  String getRules() => getString(FirebaseRemoteConfigKeys.rules);
}
