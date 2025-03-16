import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/verification/data/repositories/verification.repository.dart';
import 'package:video_compress/video_compress.dart';

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
      final verificationRepository = ref.watch(verificationRepositoryProvider);
 
 
      final response = await verificationRepository.verification();
      await ref.read(authProvider.notifier).getUpdatedUser();

      state = VerificationState.success(response.message!);
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
