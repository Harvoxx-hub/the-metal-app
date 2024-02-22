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

class UploadEyeNotifier extends StateNotifier<UploadEyeState> {
  UploadEyeNotifier(
    UploadEyeState state,
    this.ref,
  ) : super(state) {}
  final Ref ref;

  //upoad eyes
  void uploadEyes(
    String text,
    File media,
  ) async {
    try {
      state = UploadEyeState.loading();
      final eyeRepository = ref.watch(statusRepositoryProvider);

      final response =
          await eyeRepository.createStatus(text: text, media: media);
      state = UploadEyeState.success(StatusModel.fromJson(response.data));
    } catch (e) {
      print(e.toString());
      state = UploadEyeState.error(e.toString());
    }
  }
}

// Define a type alias
typedef UploadEyeState = BaseState<StatusModel>;

final uploadEyesProvider =
    StateNotifierProvider.autoDispose<UploadEyeNotifier, UploadEyeState>(
  (ref) => UploadEyeNotifier(UploadEyeState.initial(), ref),
);
