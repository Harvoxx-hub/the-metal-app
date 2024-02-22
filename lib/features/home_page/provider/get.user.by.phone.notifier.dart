import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/sparks_page/data/repositories/spark.repository.dart';
import 'package:metal/features/sparks_page/domain/entries/spark.model.dart';

class GetUserByPhoneNotifier extends StateNotifier<GetUserByPhoneState> {
  GetUserByPhoneNotifier(GetUserByPhoneState state, this.ref, this.id)
      : super(state) {
    getUserByPhone();
  }
  final Ref ref;
  final String id;

  //get user by username
  void getUserByPhone() async {
    try {
      state = GetUserByPhoneState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getUserByPhone(phone: id);
      print(response.data);

      state = GetUserByPhoneState.success(UserModel.fromJson(response.data));
    } catch (e) {
      print(e.toString());
      state = GetUserByPhoneState.error(e.toString());
    }
  }
}

// Define a type alias
typedef GetUserByPhoneState = BaseState<UserModel>;

final getUserByPhoneProvider = StateNotifierProvider.autoDispose
    .family<GetUserByPhoneNotifier, GetUserByPhoneState, String>(
  (ref, id) => GetUserByPhoneNotifier(GetUserByPhoneState.initial(), ref, id),
);
