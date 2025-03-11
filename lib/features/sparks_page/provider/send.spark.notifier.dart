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
  void sendSpark(
      {required String receiverId,
      required double numberOfSparks,
      required String receiverName}) async {
    state = SendsparkState.loading();
    try {
      final sparkRepository = ref.watch(sparkRepositoryProvider);
      final userDetails = ref.watch(authProvider).data;
      final response = await sparkRepository.shareSpark(
          numberOfSparks: numberOfSparks,
          receiverID: receiverId,
          receiverName: receiverName,
          senderName: userDetails!.username!);

      ref.read(authProvider.notifier).getUpdatedUser();
      response.success == false
          ? state = SendsparkState.error(response.message!)
          : state = SendsparkState.success({"data": "data"});
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
