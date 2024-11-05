import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
 
class DeleteUsersNotifier extends StateNotifier<DeleteUsersState> {
  DeleteUsersNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // melt user
  void DeleteUser() async {
    try {
      state = DeleteUsersState.loading();
      final repo = ref.watch(authenticationRepositoryProvider);
      final response = await repo.DeleteUser();
      if (mounted) {
        state = DeleteUsersState.success(response.message!);
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
