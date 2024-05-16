import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/eyes/data/repositories/status.repository.dart';
import 'package:metal/features/eyes/domain/entries/status.model.dart';

class GetCurrentEyeNotifier extends StateNotifier<GetCurrentEyeState> {
  GetCurrentEyeNotifier(
    super.state,
    this.ref,
  ) {
    getCurrentEye();
  }
  final Ref ref;

  // //get List of current eyes
  // void getCurrentEye() async {
  //   try {
  //     state = GetCurrentEyeState.loading();
  //     final eyeRepository = ref.watch(statusRepositoryProvider);
  //     final response = await eyeRepository.getCurrentUserStatus();
  //     final List<StatusData> eyes = [];
  //     response.data.forEach((element) {
  //       eyes.add(StatusData.fromJson(element));
  //     });
  //     state = GetCurrentEyeState.success(eyes);
  //   } catch (e) {
  //     print(e.toString());
  //     state = GetCurrentEyeState.error(e.toString());
  //   }
  // }

  //get List of current eyes
  void getCurrentEye() async {
    try {
      state = GetCurrentEyeState.loading();
      final eyeRepository = ref.watch(statusRepositoryProvider);
      final response = await eyeRepository.getCurrentUserStatus();
      if (mounted) {
        final List<StatusData> eyes = [];
        response.data.forEach((element) {
          eyes.add(StatusData.fromJson(element));
        });
        state = GetCurrentEyeState.success(eyes);
      }
    } catch (e) {
      print(e.toString());
      state = GetCurrentEyeState.error(e.toString());
    }
  }
}

// Define a type alias
typedef GetCurrentEyeState = BaseState<List<StatusData>>;

final getCurrentEyesProvider = StateNotifierProvider.autoDispose<
    GetCurrentEyeNotifier, GetCurrentEyeState>(
  (ref) => GetCurrentEyeNotifier(GetCurrentEyeState.initial(), ref),
);
