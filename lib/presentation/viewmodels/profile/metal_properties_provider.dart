import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/models/metal_properties_model.dart';
import 'package:metal/data/repositories/metal/metal_repository_providers.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Metal Properties Notifier
/// Fetches metals from API endpoint and other properties from Firebase Remote Config
class MetalPropertiesNotifier extends StateNotifier<MetalPropertiesState> {
  MetalPropertiesNotifier(super.state, this.ref) {
    getMetalProperties();
  }

  final Ref ref;
  String currentVersion = "";

  /// Get metal properties from API and Firebase Remote Config
  void getMetalProperties() async {
    state = MetalPropertiesState.loading();
    try {
      // Fetch metals from API
      final metalRepo = ref.read(metalRepositoryProvider);
      final metalsResult = await metalRepo.getMetals();

      if (!metalsResult.isSuccess || metalsResult.data == null) {
        throw Exception(metalsResult.errorMessage ?? 'Failed to fetch metals');
      }

      // Get other properties from Firebase Remote Config (if needed)
      // For now, we'll only use metals from API
      final remoteConfigProperties = FirebaseRemoteConfigService().getMetalProperties();
      final remoteConfigModel = MetalPropertiesModel.fromJson(remoteConfigProperties);

      // Combine: metals from API, other properties from Remote Config
      final metalProperties = MetalPropertiesModel(
        metals: metalsResult.data, // Metals from API
        passions: remoteConfigModel.passions,
        profession: remoteConfigModel.profession,
        education: remoteConfigModel.education,
        country: remoteConfigModel.country,
        ethnicity: remoteConfigModel.ethnicity,
        religion: remoteConfigModel.religion,
        language: remoteConfigModel.language,
        marriageStatus: remoteConfigModel.marriageStatus,
        lookingFor: remoteConfigModel.lookingFor,
        demography: remoteConfigModel.demography,
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

