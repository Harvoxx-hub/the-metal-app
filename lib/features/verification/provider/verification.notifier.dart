import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';

//import 'package:metal/features/authentication/provider/user_state_notifier.dart';

class VerificationNotifier extends StateNotifier<VerificationState> {
  VerificationNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // get metal properties
  void verificationMe() async {
    state = VerificationState.loading();
    try {
      await Future.delayed(const Duration(seconds: 3));

      // // update the user
      // await ref.read(userStateProvider.notifier).updateUserField(
      //       field: 'isVerified',
      //       value: true,
      //     );

      state = VerificationState.success('Verification successful');
    } catch (e, s) {
      state = VerificationState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef VerificationState = BaseState<String>;

final verficationVideoProvider =
    StateNotifierProvider<VerificationNotifier, VerificationState>(
  (ref) => VerificationNotifier(VerificationState.initial(), ref),
);
