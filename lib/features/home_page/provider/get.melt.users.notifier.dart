import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';

class GetMeltUsersNotifier extends StateNotifier<GetMeltUsersState> {
  GetMeltUsersNotifier(
    super.state,
    this.ref,
  ) {
    getMeltUsers();
  }

  final Ref ref;

  void getMeltUsers() async {
    try {
      state = GetMeltUsersState.loading();

      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.fetchConnections();

      response.listen((response) {
        if (response.success ?? false) {
          final List<ConnectionModel> users = [];
          for (var user in response.data) {
            users.add(ConnectionModel.fromJson(user));
          }

          // Sort the users by lastUpdatedAt in descending order
          users.sort((a, b) {
            final aUpdatedAt = DateTime.parse(a.lastUpdatedAt!);
            final bUpdatedAt = DateTime.parse(b.lastUpdatedAt!);
            return bUpdatedAt.compareTo(aUpdatedAt); // Descending order
          });

          // Set the state to success and pass the sorted list of users
          state = GetMeltUsersState.success(users);
        } else {
          // In case of an error, set the state to error with the error message and stack trace
          state = GetMeltUsersState.error(response.message ?? "");
        }
      });
    } catch (e, s) {
      // In case of an error, set the state to error with the error message and stack trace
      state = GetMeltUsersState.error(e.toString(), stackTrace: s);
    }
  }

  // Update the list of Melt users manually

  ConnectionModel? getMeltUserById(String id) {
    try {
      if (state.data != null) {
        for (var user in state.data!) {
          if (user.users.contains(id)) {
            return user;
          }
        }
      }

      return null;
    } catch (e, s) {
      return null;
    }
  }
}

typedef GetMeltUsersState = BaseState<List<ConnectionModel>>;

final getMeltUserProvider =
    StateNotifierProvider<GetMeltUsersNotifier, GetMeltUsersState>(
  (ref) => GetMeltUsersNotifier(GetMeltUsersState.initial(), ref),
);
