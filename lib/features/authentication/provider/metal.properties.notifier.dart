import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';

class MetalPropertiesNotifier extends StateNotifier<MetalPropertiesState> {
  MetalPropertiesNotifier(
    super.state,
    this.ref,
  ) {
    getMetalProperties();
  }
  final Ref ref;

  // get metal properties
  void getMetalProperties() async {
    state = MetalPropertiesState.loading();
    try {
      final metalPropertires =
          MetalPropertiesModel.fromJson(metalPropertiesJson!);
      final repo = ref.watch(authenticationRepositoryProvider);
      final response = await repo.getMetals();
    
      List<Metal> metals = [];
      response.data.forEach((element) {
        metals.add(Metal.fromJson(element));
      });
      metalPropertires.metals = metals;

      state = MetalPropertiesState.success(metalPropertires);
    } catch (e, s) {
      state = MetalPropertiesState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef MetalPropertiesState = BaseState<MetalPropertiesModel>;

final metalPropertiesProvider =
    StateNotifierProvider<MetalPropertiesNotifier, MetalPropertiesState>(
  (ref) => MetalPropertiesNotifier(MetalPropertiesState.initial(), ref),
);
