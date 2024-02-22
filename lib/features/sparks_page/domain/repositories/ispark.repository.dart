import 'package:metal/core/model/responces.dart';

abstract class ISparkRepository {
  Future<Responses> getSparkHistory();
  Future<Responses> buySpark(
      {required double numberOfSpark, required double amount});
  Future<Responses> shareSpark(
      {required double numberOfSparks, required String receiverID});
}
