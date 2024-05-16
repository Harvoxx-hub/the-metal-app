import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/sparks_page/data/repositories/spark.repository.dart';

class BuySparkNotifier extends StateNotifier<BuysparkState> {
  BuySparkNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  //buy spark
  void buySpark({
    required double amount,
    required double numberOfSpark,
  }) async {
    state = BuysparkState.loading();
    try {
      final sparkRepository = ref.watch(sparkRepositoryProvider);
      final response = await sparkRepository.buySpark(
        amount: amount,
        numberOfSpark: numberOfSpark,
      );
      ref.read(authProvider.notifier).getUpdatedUser();
      state = BuysparkState.success(response.data);
    } catch (e) {
      print(e.toString());
      state = BuysparkState.error(e.toString());
    }
  }
}

// Define a type alias
typedef BuysparkState = BaseState<Map>;

final buySparkProvider =
    StateNotifierProvider.autoDispose<BuySparkNotifier, BuysparkState>(
  (ref) => BuySparkNotifier(BuysparkState.initial(), ref),
);
