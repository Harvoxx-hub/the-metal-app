import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/upgrade/data/repositories/subscription.repository.dart';
import 'package:metal/features/upgrade/domain/entries/metal.plan.model.dart';
import 'package:metal/features/verification/data/repositories/verification.repository.dart';

class VerificationNotifier extends StateNotifier<VerificationState> {
  VerificationNotifier(
    VerificationState state,
    this.ref,
  ) : super(state) {}
  final Ref ref;

  // get metal properties
  void verificationMe(File file) async {
    state = VerificationState.loading();
    try {
      final verificationRepository = ref.watch(verificationRepositoryProvider);
      final response = await verificationRepository.verification(file);

      state = VerificationState.success(response.data);
    } catch (e) {
      print(e.toString());
      state = VerificationState.error(e.toString());
    }
  }
}

// Define a type alias
typedef VerificationState = BaseState<String>;

final verficationVideoProvider =
    StateNotifierProvider<VerificationNotifier, VerificationState>(
  (ref) => VerificationNotifier(VerificationState.initial(), ref),
);
