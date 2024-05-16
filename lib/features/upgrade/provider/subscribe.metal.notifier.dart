import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/upgrade/data/repositories/subscription.repository.dart';
import 'package:metal/features/upgrade/domain/entries/subscribed.plan.model.dart';

class SubscribeMetalNotifier extends StateNotifier<SubscribeMetalState> {
  SubscribeMetalNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // get metal properties
  void subscribeMetalPlan(
    String Id,
  ) async {
    state = SubscribeMetalState.loading();
    try {
      final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
      final response = await subscriptionRepository.subscribeMetalPlan(Id);
      ref.read(authProvider.notifier).getUpdatedUser();
      state = SubscribeMetalState.success(SubscribedPlanModel.fromJson(response.data));
    } catch (e) {
      print(e.toString());
      state = SubscribeMetalState.error(e.toString());
    }
  }
}

// Define a type alias
typedef SubscribeMetalState = BaseState<SubscribedPlanModel>;

final subscribeMetalProvider =
    StateNotifierProvider<SubscribeMetalNotifier, SubscribeMetalState>(
  (ref) => SubscribeMetalNotifier(SubscribeMetalState.initial(), ref),
);
