import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';

class MetalPropertiesNotifier extends StateNotifier<MetalPropertiesState> {
  MetalPropertiesNotifier(
    MetalPropertiesState state,
    this.ref,
  ) : super(state) {
    getMetalProperties();
  }
  final Ref ref;

  // get metal properties
  void getMetalProperties() async {
    state = MetalPropertiesState.loading();
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.getMetalProperties();
      final metalPropertires = MetalPropertiesModel.fromJson(response.data);
      state = MetalPropertiesState.success(metalPropertires);
    } catch (e) {
      print(e.toString());
      state = MetalPropertiesState.error(e.toString());
    }
  }
}

// Define a type alias
typedef MetalPropertiesState = BaseState<MetalPropertiesModel>;

final metalPropertiesProvider =
    StateNotifierProvider<MetalPropertiesNotifier, MetalPropertiesState>(
  (ref) => MetalPropertiesNotifier(MetalPropertiesState.initial(), ref),
);
