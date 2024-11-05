import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/sparks_page/data/repositories/spark.repository.dart';

class SendSparkNotifier extends StateNotifier<SendsparkState> {
  SendSparkNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  //send spark
  void sendSpark({
    required String receiverId,
    required double numberOfSparks,
  }) async {
    state = SendsparkState.loading();
    try {
      final sparkRepository = ref.watch(sparkRepositoryProvider);
      final response = await sparkRepository.shareSpark(
        numberOfSparks: numberOfSparks,
        receiverID: receiverId,
      );
      ref.read(authProvider.notifier).getUpdatedUser();
      state = SendsparkState.success(response.data);
    } catch (e, s) {
   
      state = SendsparkState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef SendsparkState = BaseState<Map>;

final sendSparkProvider =
    StateNotifierProvider.autoDispose<SendSparkNotifier, SendsparkState>(
  (ref) => SendSparkNotifier(SendsparkState.initial(), ref),
);
