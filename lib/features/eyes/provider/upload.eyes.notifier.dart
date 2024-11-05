import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/eyes/data/repositories/status.repository.dart';
import 'package:metal/features/eyes/domain/entries/status.model.dart';

class UploadEyeNotifier extends StateNotifier<UploadEyeState> {
  UploadEyeNotifier(
    super.state,
    this.ref,
  );
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
    } catch (e, s) {
  
      state = UploadEyeState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef UploadEyeState = BaseState<StatusModel>;

final uploadEyesProvider =
    StateNotifierProvider.autoDispose<UploadEyeNotifier, UploadEyeState>(
  (ref) => UploadEyeNotifier(UploadEyeState.initial(), ref),
);
