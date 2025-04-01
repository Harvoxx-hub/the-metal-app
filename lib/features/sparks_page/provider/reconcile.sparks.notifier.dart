import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/sparks_page/data/repositories/spark.repository.dart';

class ReconcileSparkNotifier extends StateNotifier<ReconcileSparkState> {
  ReconcileSparkNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // Reconcile the spark balance
  void reconcileSparkBalance() async {
    if (!mounted) return;
    state = ReconcileSparkState.loading();

    try {
      final sparkRepository = ref.watch(sparkRepositoryProvider);
      final response = await sparkRepository.reconcileSparkTransactions();

      if (!mounted) return;

      if (response.success == true) {
        // Update user data to reflect the new balance
        ref.read(authProvider.notifier).getUpdatedUser();
        state = ReconcileSparkState.success(response.data ?? {});
      } else {
        state = ReconcileSparkState.error(
            response.message ?? "Failed to reconcile spark balance");
      }
    } catch (e, s) {
      if (!mounted) return;
      state = ReconcileSparkState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef ReconcileSparkState = BaseState<Map<String, dynamic>>;

final reconcileSparkProvider = StateNotifierProvider.autoDispose<
    ReconcileSparkNotifier, ReconcileSparkState>(
  (ref) => ReconcileSparkNotifier(ReconcileSparkState.initial(), ref),
);
