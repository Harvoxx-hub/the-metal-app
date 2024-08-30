import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';

class CheckMeltStatusNotifier extends StateNotifier<CheckMeltState> {
  CheckMeltStatusNotifier(
    super.state,
    this.ref,
    this.id
  ) {
    checkStatus();
  }
  final Ref ref;
  final String id;

  //get all users
  void checkStatus() async {
    try {
      state = CheckMeltState.loading();
      final repository = ref.watch(homeRepositoryProvider);

      final response = await repository.checkMelt(userId: id);

      state = CheckMeltState.success(response.data["status"]);
    } catch (e) {
      print(e.toString());
      state = CheckMeltState.error(e.toString());
    }
  }
}

// Define a type alias
typedef CheckMeltState = BaseState<String>;

final checkMeltProvider =
    StateNotifierProvider.family.autoDispose<CheckMeltStatusNotifier, CheckMeltState,String>(
  (ref, id) => CheckMeltStatusNotifier(CheckMeltState.initial(), ref, id),
);
