import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/utils/constant/firebase.remote.config.key.dart';

class UnmeltDaysNotifier extends StateNotifier<int> {
  UnmeltDaysNotifier() : super(0) {
    _fetchDaysRequiredToUnMelt();
  }

  void _fetchDaysRequiredToUnMelt() {
    final int daysRequiredToUnMelt = FirebaseRemoteConfigService()
        .getInt(FirebaseRemoteConfigKeys.daysRequiredToUnMelt);
    state = daysRequiredToUnMelt;
  }
}

final numberDaysProvider =
    StateNotifierProvider<UnmeltDaysNotifier, int>((ref) {
  return UnmeltDaysNotifier();
});
