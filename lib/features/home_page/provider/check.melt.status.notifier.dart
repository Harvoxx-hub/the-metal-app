import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/constant/enums.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';

class CheckMeltStatusNotifier extends StateNotifier<CheckMeltState> {
  CheckMeltStatusNotifier(super.state, this.ref, this.id) {
    checkStatus();
  }
  final Ref ref;
  final String id;

  void checkStatus() async {
    try {
      state = CheckMeltState.loading();
      final repository = ref.watch(homeRepositoryProvider);

      final response = await repository.checkMelt(user2Id: id);

      if (mounted) {
        state = CheckMeltState.success(response.data);
      }
    } catch (e, s) {
      state = CheckMeltState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef CheckMeltState = BaseState<MeltRequestState>;

final checkMeltProvider = StateNotifierProvider.family
    .autoDispose<CheckMeltStatusNotifier, CheckMeltState, String>(
  (ref, id) => CheckMeltStatusNotifier(CheckMeltState.initial(), ref, id),
);
