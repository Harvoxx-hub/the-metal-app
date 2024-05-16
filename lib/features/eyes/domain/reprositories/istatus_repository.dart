import 'dart:io';

import 'package:metal/core/model/responces.dart';

abstract class IStatusRepository {
  Future<Responses> createStatus({
    required String text,
    required File media,
  });

  //getnstatus
  Future<Responses> getStatus();
  //get user by
   Future<Responses> getCurrentUserStatus();

  //verifi
}
