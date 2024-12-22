import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/refer.earn/data/refer.repository.dart';

class GetRefferedUserNotifier extends StateNotifier<GetRefferedUserState> {
  GetRefferedUserNotifier(
    super.state,
    this.ref,
  ) {
    getReffered();
  }
  final Ref ref;

  void getReffered() async {
    try {
      state = GetRefferedUserState.loading();
      final repo = ref.watch(referRepositoryProvider);
      final response = await repo.getReferCount();

      if (response.success ?? false) {
        final List<UserModel> users = [];
        for (var user in response.data) {
          users.add(UserModel.fromJson(user));
        }
        state = GetRefferedUserState.success(users);
      } else {
        state = GetRefferedUserState.error(response.message ?? "");
      }
    } catch (e, s) {
      state = GetRefferedUserState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetRefferedUserState = BaseState<List<UserModel>>;

final getRefferedUserProvider = StateNotifierProvider.autoDispose<
    GetRefferedUserNotifier, GetRefferedUserState>(
  (ref) => GetRefferedUserNotifier(GetRefferedUserState.initial(), ref),
);
