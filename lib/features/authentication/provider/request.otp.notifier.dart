import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

class RequestOtpNotifier extends StateNotifier<RequestOtpStates> {
  RequestOtpNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  void requestOtp({
    required String email,
  }) async {
    state = RequestOtpStates.loading();
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.forgetPassword(
        email,
      );

      state = RequestOtpStates.success(response.data);
    } catch (e, s) {
      state = RequestOtpStates.error(e.toString(), stackTrace: s);
    }
  }
}

typedef RequestOtpStates = BaseState<Map>;

final requestOtpProvider =
    StateNotifierProvider.autoDispose<RequestOtpNotifier, RequestOtpStates>(
  (ref) => RequestOtpNotifier(RequestOtpStates.initial(), ref),
);
