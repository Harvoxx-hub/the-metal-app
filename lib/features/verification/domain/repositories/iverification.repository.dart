import 'dart:io';

import 'package:metal/core/model/responces.dart';

abstract class IVerificationRepository {
  Future<Responses> verification();
}
