import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';

class VerficationNotifier extends StateNotifier<VerficationState> {
  VerficationNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  void activateAccount(String UUID) async {
    state = VerficationState.loading();
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      await authenticationRepository.updateUser({
        "emailVerified": true,
      });

      state = VerficationState.success("");
    } catch (e, s) {
      state = VerficationState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef VerficationState = BaseState<String>;

final verficationProvider =
    StateNotifierProvider.autoDispose<VerficationNotifier, VerficationState>(
  (ref) => VerficationNotifier(VerficationState.initial(), ref),
);
