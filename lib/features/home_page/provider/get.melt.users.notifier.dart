import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';
import 'package:metal/features/sparks_page/data/repositories/spark.repository.dart';
import 'package:metal/features/sparks_page/domain/entries/spark.model.dart';

class GetMeltUsersNotifier extends StateNotifier<GetMeltUsersState> {
  GetMeltUsersNotifier(
    GetMeltUsersState state,
    this.ref,
  ) : super(state) {
    getMeltUsers();
  }
  final Ref ref;
  

  //get melt users
  void getMeltUsers() async {
    try {
      state = GetMeltUsersState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getMeltedUsers();
      final List<MeltUserModel> users = [];
      for (var user in response.data) {
        users.add(MeltUserModel.fromJson(user));
      }
      state = GetMeltUsersState.success(users);
      
    } catch (e) {
      print(e.toString());
      state = GetMeltUsersState.error(e.toString());
    }
  }
}

// Define a type alias
typedef GetMeltUsersState = BaseState<List<MeltUserModel>>;

final getMeltUserProvider =
    StateNotifierProvider.autoDispose<GetMeltUsersNotifier, GetMeltUsersState>(
  (ref) => GetMeltUsersNotifier(GetMeltUsersState.initial(), ref),
);
