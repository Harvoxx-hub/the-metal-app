import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/models/metal_properties_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Metal Properties Notifier
/// Fetches metal properties from Firebase Remote Config
class MetalPropertiesNotifier extends StateNotifier<MetalPropertiesState> {
  MetalPropertiesNotifier(super.state, this.ref) {
    getMetalProperties();
  }

  final Ref ref;
  String currentVersion = "";

  /// Get metal properties from remote config
  void getMetalProperties() async {
    state = MetalPropertiesState.loading();
    try {
      final metalProperties = MetalPropertiesModel.fromJson(
        FirebaseRemoteConfigService().getMetalProperties(),
      );

      // Get app version
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      currentVersion = "${packageInfo.version}+${packageInfo.buildNumber}";

      state = MetalPropertiesState.success(metalProperties);
    } catch (e, s) {
      state = MetalPropertiesState.error(e.toString(), stackTrace: s);
    }
  }
}

/// Type alias for metal properties state
typedef MetalPropertiesState = BaseState<MetalPropertiesModel>;

/// Metal Properties Provider
final metalPropertiesProvider =
    StateNotifierProvider<MetalPropertiesNotifier, MetalPropertiesState>(
  (ref) => MetalPropertiesNotifier(MetalPropertiesState.initial(), ref),
);

