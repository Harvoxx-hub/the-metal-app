 
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';

class GetMeltUsersNotifier extends StateNotifier<GetMeltUsersState> {
  GetMeltUsersNotifier(
    super.state,
    this.ref,
  ) {
    // Fetch the list of Melt users when the notifier is instantiated
    getMeltUsers();
  }
  
  final Ref ref;

  // Fetch all Melt users and update the state accordingly
  void getMeltUsers() async {
    try {
      // Set the state to loading while fetching data
      state = GetMeltUsersState.loading();
      
      // Access the home repository to fetch Melt users
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getMeltedUsers();

      // Parse the response data into a list of MeltUserModel
      final List<MeltUserModel> users = [];
      for (var user in response.data) {
        users.add(MeltUserModel.fromJson(user));
      }

      // Set the state to success and pass the list of users
      state = GetMeltUsersState.success(users);
    } catch (e, s) {
      // In case of an error, set the state to error with the error message and stack trace
      state = GetMeltUsersState.error(e.toString(), stackTrace: s);
    }
  }

  // Update the list of Melt users manually
  void updateMelt() async {
    try {
      // Access the home repository to fetch Melt users
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getMeltedUsers();

      // Parse the response data into a list of MeltUserModel
      final List<MeltUserModel> users = [];
      for (var user in response.data) {
        users.add(MeltUserModel.fromJson(user));
      }

      // Set the state to success and pass the list of users
      state = GetMeltUsersState.success(users);
    } catch (e) {
      // Log the error in case of failure
      print(e.toString());
    }
  }

  // Retrieve a specific Melt user by their ID from the current state
  MeltUserModel? getMeltUserById(String id)  {
    try {
      // Check if the state contains a valid list of users
      if (state.data != null) {
        // Iterate over the users and find the one matching the provided ID
        for (var user in state.data!) {
          if (user.id == id) {
            return user;
          }
        }
      }

      // Return null if no user is found with the provided ID
      return null;
    } catch (e, s) {
      // Log the error in case of an exception
   print(e.toString());
      return null;
    }
  }
}

// Define a type alias for the state that holds a list of MeltUserModel
typedef GetMeltUsersState = BaseState<List<MeltUserModel>>;

// Provider for the GetMeltUsersNotifier, initializing it with an empty state
final getMeltUserProvider =
    StateNotifierProvider<GetMeltUsersNotifier, GetMeltUsersState>(
  (ref) => GetMeltUsersNotifier(GetMeltUsersState.initial(), ref),
);
