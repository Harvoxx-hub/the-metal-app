import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/spark_dto.dart';

abstract class SparkRepositoryAbstract {
  Future<BaseState<SparkDto>> getSparks();
  Future<BaseState<SparkTransactionDto>> sendSparks({
    required String recipientId,
    required int amount,
    String? message,
  });
}
