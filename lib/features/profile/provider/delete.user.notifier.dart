import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/route/routes.dart';

class DeleteUsersNotifier extends StateNotifier<DeleteUsersState> {
  DeleteUsersNotifier(super.state, this.ref);
  final Ref ref;

  Future<void> deleteUser(BuildContext context) async {
    try {
      state = DeleteUsersState.loading();
      final repo = ref.watch(authenticationRepositoryProvider);
      final response = await repo.deleteUser();

      if (mounted) {
        state = DeleteUsersState.success(response.message!);

 
        // Navigate after deletion is successful

        Navigator.pushReplacementNamed(context, AppRoutes.splash);
      }
    } catch (e, s) {
      state = DeleteUsersState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef DeleteUsersState = BaseState<String>;

final deleteUserProvider =
    StateNotifierProvider.autoDispose<DeleteUsersNotifier, DeleteUsersState>(
  (ref) => DeleteUsersNotifier(DeleteUsersState.initial(), ref),
);
