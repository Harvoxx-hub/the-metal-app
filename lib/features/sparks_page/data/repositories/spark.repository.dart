import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';

import 'package:metal/features/sparks_page/domain/repositories/ispark.repository.dart';

class SparkRepository implements ISparkRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Responses> buySpark(
      {required double numberOfSpark, required double amount}) async {
    try {
      final response = await _apiService.post(
        "spark/buy",
        body: {
          "numberOfSpark": numberOfSpark,
          "amount": amount,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getSparkHistory() async {
    try {
      final response = await _apiService.get("spark/history");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> shareSpark(
      {required double numberOfSparks, required String receiverID}) async {
    try {
      final response = await _apiService.post(
        "spark/share",
        body: {
          "numberOfSparks": numberOfSparks,
          "receiverID": receiverID,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final sparkRepositoryProvider = Provider((ref) {
  return SparkRepository();
});
