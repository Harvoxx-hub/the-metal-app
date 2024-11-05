
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/eyes/data/repositories/status.repository.dart';
import 'package:metal/features/eyes/domain/entries/status.model.dart';

class GetAllEyeNotifier extends StateNotifier<GetAllEyeState> {
  GetAllEyeNotifier(
    super.state,
    this.ref,
  ) {
    getAlltEye();
  }
  final Ref ref;

  //upoad eyes
  // //get List of current eyes
  void getAlltEye() async {
    try {
      state = GetAllEyeState.loading();
      final eyeRepository = ref.watch(statusRepositoryProvider);
      final response = await eyeRepository.getStatus();
      final List<StatusData> eyes = [];
      response.data.forEach((element) {
        eyes.add(StatusData.fromJson(element));
      });
      state = GetAllEyeState.success(eyes);
    } catch (e, s) {
 
      state = GetAllEyeState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetAllEyeState = BaseState<List<StatusData>>;

final getAllEyesProvider =
    StateNotifierProvider.autoDispose<GetAllEyeNotifier, GetAllEyeState>(
  (ref) => GetAllEyeNotifier(GetAllEyeState.initial(), ref),
);
