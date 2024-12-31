import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

class SendFeedbackNotifier extends StateNotifier<SendFeedbackState> {
  SendFeedbackNotifier(this.ref) : super(SendFeedbackState.initial());

  final Ref ref;

  Future<void> sendFeedback(String feedback) async {
    try {
      state = SendFeedbackState.loading();

      final authRepository = ref.watch(authenticationRepositoryProvider);
      final response = await authRepository.sendFeedback(feedback);

      if (response.success!) {
        Fluttertoast.showToast(msg: response.message ?? "");
        state = SendFeedbackState.success(response.message ?? "");
      } else {
        state = SendFeedbackState.error(
            response.message ?? 'Failed to send Feedback');
      }
    } catch (e) {
      state = SendFeedbackState.error('Failed to send Feedback: $e');
    }
  }
}

typedef SendFeedbackState = BaseState<String>;

final sendFeedbackProvider =
    StateNotifierProvider.autoDispose<SendFeedbackNotifier, SendFeedbackState>(
  (ref) => SendFeedbackNotifier(ref),
);
