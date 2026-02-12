import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/data/datasources/remote/spark_remote_data_source.dart';
import 'package:metal/data/repositories/spark/spark_repository_abstract.dart';
import 'package:metal/domain/entities/spark_dto.dart';

class SparkRepository implements SparkRepositoryAbstract {
  final SparkRemoteDataSource _remoteDataSource;

  SparkRepository({required SparkRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<BaseState<SparkDto>> getSparks() async {
    try {
      final response = await _remoteDataSource.getSparks();
      final spark = response.toDomain();
      return BaseState.success(spark);
    } catch (e) {
      return ErrorHandler.handleError<SparkDto>(e);
    }
  }

  @override
  Future<BaseState<SparkTransactionDto>> sendSparks({
    required String recipientId,
    required int amount,
    String? message,
  }) async {
    try {
      final response = await _remoteDataSource.sendSparks(
        recipientId: recipientId,
        amount: amount,
        message: message,
      );
      return BaseState.success(response.transaction.toDomain());
    } catch (e) {
      return ErrorHandler.handleError<SparkTransactionDto>(e);
    }
  }
}
