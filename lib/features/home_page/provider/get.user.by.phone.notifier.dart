import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';

class GetUserByPhoneNotifier extends StateNotifier<GetUserByPhoneState> {
  GetUserByPhoneNotifier(super.state, this.ref, this.id) {
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
    } catch (e, s) {
 
      state = GetUserByPhoneState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetUserByPhoneState = BaseState<UserModel>;

final getUserByPhoneProvider = StateNotifierProvider.autoDispose
    .family<GetUserByPhoneNotifier, GetUserByPhoneState, String>(
  (ref, id) => GetUserByPhoneNotifier(GetUserByPhoneState.initial(), ref, id),
);
