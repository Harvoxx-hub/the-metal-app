import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/sparks_page/data/repositories/spark.repository.dart';
import 'package:metal/features/sparks_page/domain/entries/spark.model.dart';

class GetUserNotifier extends StateNotifier<GetUserState> {
  GetUserNotifier(
    GetUserState state,
    this.ref,
    this.id
  ) : super(state) {
    getUserById();
  }
  final Ref ref;
  final String id;

  //get user by username
  void getUserById() async {
    try {
      state = GetUserState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getUserById(id: id);
      print(response.data);

      state = GetUserState.success(UserModel.fromJson(response.data));
      
    } catch (e) {
      print(e.toString());
      state = GetUserState.error(e.toString());
    }
  }
}

// Define a type alias
typedef GetUserState = BaseState<UserModel>;

final getUserProvider =
    StateNotifierProvider.autoDispose.family<GetUserNotifier, GetUserState, String>(
  (ref, id) => GetUserNotifier(GetUserState.initial(), ref, id),
);
