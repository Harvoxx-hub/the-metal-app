import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

class VerficationNotifier extends StateNotifier<VerficationState> {
  VerficationNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  void activateAccount() async {
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      await authenticationRepository.updateUser({
        "emailVerified": true,
      });
    } catch (e, s) {
      state = VerficationState.error(e.toString(), stackTrace: s);
    }
  }

  Future<void> sendVerificationCode(String email) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('sendVerificationCode');
      await callable.call({'email': email});
    } catch (e) {
      state = VerficationState.error('Failed to send verification code: $e');
    }
  }

  Future<void> verifyCode(
    String email,
    String code, {
    String? from,
  }) async {
    state = VerficationState.loading();
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('verifyCode');
      final response =
          await callable.call({'email': email, 'code': int.parse(code)});

      if (response.data['success']) {
        if (from == "WorkEmail") {
          final authenticationRepository =
              ref.watch(authenticationRepositoryProvider);
          await authenticationRepository.updateUser({
            "workEmail": email,
            "workEmailVerified": true,
          });
        } else {
          activateAccount();
        }
        // refresh the user date
        await ref.read(userStateProvider.notifier).refreshUser();
        state = VerficationState.success("");
      } else {
        state = VerficationState.error(response.data['message']);
      }
    } catch (e) {
      state = VerficationState.error('Failed to verify code: $e');
    }
  }
}

// Define a type alias
typedef VerficationState = BaseState<String>;

final verficationProvider =
    StateNotifierProvider.autoDispose<VerficationNotifier, VerficationState>(
  (ref) => VerficationNotifier(VerficationState.initial(), ref),
);
