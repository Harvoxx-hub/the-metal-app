import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';

class GetUsersNotifier extends StateNotifier<GetUsersState> {
  GetUsersNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  //get user by username
  void getUserByquery({required String query}) async {
    try {
      state = GetUsersState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getUserByUsername(username: query);
      print(response.data);
      if (mounted) {
        if (response.data is List) {
          // Check if every element in the list is a map
          bool isListMap = response.data.every((element) => element is Map);
          if (isListMap) {
            // Cast response.data to List<Map<dynamic, dynamic>>
            state = GetUsersState.success(
                response.data.cast<Map<dynamic, dynamic>>());
          } else {
            throw Exception("Response data is not a list of maps");
          }
        } else {
          throw Exception("Response data is not a list");
        }
      }
    } catch (e) {
      print(e.toString());
      state = GetUsersState.error(e.toString());
    }
  }
}

// Define a type alias
typedef GetUsersState = BaseState<List<Map>>;

final getUserByNameProvider =
    StateNotifierProvider.autoDispose<GetUsersNotifier, GetUsersState>(
  (ref) => GetUsersNotifier(GetUsersState.initial(), ref),
);
