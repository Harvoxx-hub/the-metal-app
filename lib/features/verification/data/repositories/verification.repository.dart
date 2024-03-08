import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';

import 'package:metal/features/verification/domain/repositories/iverification.repository.dart';

class VerificationRepository implements IVerificationRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Responses> verification(File file) async {
    try {
      final response = await _apiService.post(
        "user/update-profile-photo",
        formData: FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path),
        }),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final verificationRepositoryProvider = Provider((ref) {
  return VerificationRepository();
});
