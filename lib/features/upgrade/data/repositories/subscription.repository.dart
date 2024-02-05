import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';

import 'package:metal/features/upgrade/domain/repositories/isubscription.repository.dart';

class SubscriptionRepository implements ISubscriptionRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Responses> getMetalPlan() async {
    try {
      final response = await _apiService.get("metal-properties/metal-palns");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final subscriptionRepositoryProvider = Provider((ref) {
  return SubscriptionRepository();
});
