import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/upgrade/data/repositories/subscription.repository.dart';
import 'package:metal/features/upgrade/domain/entries/metal.plan.model.dart';

class MetalPlanNotifier extends StateNotifier<MetalPlanState> {
  MetalPlanNotifier(
    MetalPlanState state,
    this.ref,
  ) : super(state) {
    getMetalPlans();
  }
  final Ref ref;

  // get metal properties
  void getMetalPlans() async {
    state = MetalPlanState.loading();
    try {
      final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
      final response = await subscriptionRepository.getMetalPlan();
      final metalPlans = (response.data as List)
          .map((e) => MetalPlanModel.fromJson(e))
          .toList();
      state = MetalPlanState.success(metalPlans);
    } catch (e) {
      print(e.toString());
      state = MetalPlanState.error(e.toString());
    }
  }
}

// Define a type alias
typedef MetalPlanState = BaseState<List<MetalPlanModel>>;

final metalPlansProvider =
    StateNotifierProvider<MetalPlanNotifier, MetalPlanState>(
  (ref) => MetalPlanNotifier(MetalPlanState.initial(), ref),
);
