import 'package:metal/core/model/responces.dart';

abstract class IReferRepository {
  Future<Responses> getReferCount();
 
}
