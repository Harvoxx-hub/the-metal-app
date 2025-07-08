import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
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
      //  state = GetMeltUsersState.loading();

      final homeRepository = ref.watch(homeRepositoryProvider);
      final authState = ref.watch(userStateProvider).data;
      if (authState == null) {
        state = GetMeltUsersState.error("User not authenticated");
        return;
      }

      final response = await homeRepository.fetchConnections();

      response.listen((response) async {
        if (response.success ?? false) {
          final List<ConnectionModel> users = [];

          for (var user in response.data) {
            var connection = ConnectionModel.fromJson(user);

            // Identify the other user ID
            String? otherUserId = connection.users
                .firstWhere((id) => id != authState.id, orElse: () => '');

            if (otherUserId.isNotEmpty) {
              ///TODO: handle deleted users from showing in the list
              final response = await ref
                  .watch(authenticationRepositoryProvider)
                  .getUserByID(id: otherUserId);
              connection = connection.copyWith(
                  otherUser: UserModel.fromJson(response.data));
            }

            users.add(connection);
          }

          // Sort the users by lastUpdatedAt in descending order
          users.sort((a, b) {
            final aUpdatedAt = a.lastUpdatedAt != null
                ? DateTime.parse(a.lastUpdatedAt!)
                : DateTime(0);
            final bUpdatedAt = b.lastUpdatedAt != null
                ? DateTime.parse(b.lastUpdatedAt!)
                : DateTime(0);
            return bUpdatedAt.compareTo(aUpdatedAt);
          });
          if (mounted) {
            state = GetMeltUsersState.success(users);
          }
          // Set the state to success with the sorted list
        } else {
          state = GetMeltUsersState.error(response.message ?? "");
        }
      });
    } catch (e, s) {
      state = GetMeltUsersState.error(e.toString(), stackTrace: s);
    }
  }

  // Get a specific connection by user ID
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

  List<ConnectionModel> filterUsers(String query) {
    if (query.isEmpty) {
      return state.data ?? [];
    }

    final filteredUsers = state.data!.where((user) {
      return user.otherUser?.username!
              .toLowerCase()
              .contains(query.toLowerCase()) ??
          false;
    }).toList();

    return filteredUsers;
  }
}

typedef GetMeltUsersState = BaseState<List<ConnectionModel>>;

final getMeltUserProvider =
    StateNotifierProvider<GetMeltUsersNotifier, GetMeltUsersState>(
  (ref) => GetMeltUsersNotifier(GetMeltUsersState.initial(), ref),
);
