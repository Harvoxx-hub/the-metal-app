import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/verification/data/repositories/verification.repository.dart';
import 'package:video_compress/video_compress.dart';

class VerificationNotifier extends StateNotifier<VerificationState> {
  VerificationNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // get metal properties
  void verificationMe(File file) async {
    state = VerificationState.loading();
    try {
      final verificationRepository = ref.watch(verificationRepositoryProvider);

      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      print(info!.filesize.toString());
      final response = await verificationRepository.verification(info.file!);
      ref.read(authProvider.notifier).getUpdatedUser();

      state = VerificationState.success(response.message!);
    } catch (e) {
      print(e.toString());
      state = VerificationState.error(e.toString());
    }
  }
}

// Define a type alias
typedef VerificationState = BaseState<String>;

final verficationVideoProvider =
    StateNotifierProvider<VerificationNotifier, VerificationState>(
  (ref) => VerificationNotifier(VerificationState.initial(), ref),
);
