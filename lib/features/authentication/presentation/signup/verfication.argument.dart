import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';

class VerificationSentArgument {
  VerificationSentArgument(
      {required this.type, this.code, this.uuid, this.phoneNumber, this.email});

  final RouteFrom type;
  final int? code;
  final String? phoneNumber;
  final String? email;
  final String? uuid;
}
