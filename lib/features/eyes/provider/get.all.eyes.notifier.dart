import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/eyes/data/repositories/status.repository.dart';
import 'package:metal/features/eyes/domain/entries/status.model.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/sparks_page/data/repositories/spark.repository.dart';
import 'package:metal/features/sparks_page/domain/entries/spark.model.dart';

class GetAllEyeNotifier extends StateNotifier<GetAllEyeState> {
  GetAllEyeNotifier(
    GetAllEyeState state,
    this.ref,
  ) : super(state) {
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
    } catch (e) {
      print(e.toString());
      state = GetAllEyeState.error(e.toString());
    }
  }
}

// Define a type alias
typedef GetAllEyeState = BaseState<List<StatusData>>;

final getAllEyesProvider =
    StateNotifierProvider.autoDispose<GetAllEyeNotifier, GetAllEyeState>(
  (ref) => GetAllEyeNotifier(GetAllEyeState.initial(), ref),
);
