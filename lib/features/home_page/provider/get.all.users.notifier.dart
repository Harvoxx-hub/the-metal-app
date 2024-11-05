import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';

class GetUsersNotifier extends StateNotifier<GetAllUsersState> {
  GetUsersNotifier(
    super.state,
    this.ref,
  ) {
   // getAllUsers();
  }
  final Ref ref;

  //get all users
  void getAllUsers() async {
    try {
      state = GetAllUsersState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final userData = ref.watch(authProvider).data;
      final response = await homeRepository.getALLUser(userData!.distance!);
      final List<ALLUserModel> users = [];
      response.data.forEach((element) {
        users.add(ALLUserModel.fromJson(element));
      });
     if (mounted) {
        state = GetAllUsersState.success(users);
      }
    } catch (e, s) {
 
      state = GetAllUsersState.error(e.toString(), stackTrace: s);
    }
  }

  //filter users if melted is true dont add to list
  // void filterUsers(List<ALLUserModel> users) {
  //   final List<ALLUserModel> filteredUsers = [];
  //   users.forEach((element) {
  //     if (!element.melted) {
  //       filteredUsers.add(element);
  //     }
  //   });
  //   if (mounted) {
  //       state = GetAllUsersState.success(filteredUsers);
  //     }
  
  // }

  //remove user from list
  void removeUser(String id) {
    final List<ALLUserModel> users = state.data!;
    users.removeWhere((element) => element.id == id);
    state = GetAllUsersState.success(users);
  }
}

// Define a type alias
typedef GetAllUsersState = BaseState<List<ALLUserModel>>;

final getAllUserProvider =
    StateNotifierProvider.autoDispose<GetUsersNotifier, GetAllUsersState>(
  (ref) => GetUsersNotifier(GetAllUsersState.initial(), ref),
);
