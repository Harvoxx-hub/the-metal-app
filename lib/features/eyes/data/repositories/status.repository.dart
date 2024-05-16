import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';

import 'package:metal/features/eyes/domain/reprositories/istatus_repository.dart';

class StatusRepository implements IStatusRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Responses> createStatus(
      {required String text, required File media}) async {
    try {
      final response = await _apiService.post(
        'user/upload-status',
        formData: FormData.fromMap({
          "text": text,
          "file": await MultipartFile.fromFile(media.path),
        }),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getStatus() async {
    try {
      final response = await _apiService.get(
        'user/view-status',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getCurrentUserStatus() async {
    try {
      final response = await _apiService.get(
        'user/retrieve-my-status',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final statusRepositoryProvider = Provider((ref) {
  return StatusRepository();
});
