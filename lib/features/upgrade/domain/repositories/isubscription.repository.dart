import 'package:metal/core/model/responces.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

abstract class ISubscriptionRepository {
  Future<Responses> getMetalPlan();

 Future<Responses> subscribeMetalPlan(String Id);

  //get user by

  //verifi
}
