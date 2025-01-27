import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

class LoginNotifier extends StateNotifier<LoginStates> {
  LoginNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;
//   void login({
//     required String email,
//     required String password,
//   }) async {
//     state = LoginStates.loading();
//     debugPrint("LOGIN STATE:$state");
//     try {
//       final authenticationRepository =
//           ref.watch(authenticationRepositoryProvider);
//       final response = await authenticationRepository.logIn(
//         email: email,
//         password: password,
//       );

//       if (response.success!) {
//         final Map<String, dynamic> data = response.data;
//         ref
//             .read(authProvider.notifier)
//             .updateUserData(UserModel.fromJson(data));

//         state = LoginStates.success(UserModel.fromJson(data));
//         debugPrint("LOGIN RESPONSE SUCCESS:${response.success}");
//       } else {
//         debugPrint("LOGIN ERROR RESPONSE:$response");
//         state = LoginStates.error(
//           response.message!,
//         );
//       }
//     } catch (e, s) {
//       debugPrint('LOGIN Error: $e, LOGIN StackTrace: $s');
//       state = LoginStates.error(e.toString(), stackTrace: s);
//     }
//   }
// }

  //login user
  void login({
    required String email,
    required String password,
  }) async {
    state = LoginStates.loading();
    debugPrint("LOGIN STATE:$state");
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.logIn(
        email: email,
        password: password,
      );

      if (response.success!) {
        final Map<String, dynamic> data = response.data;
        ref
            .read(authProvider.notifier)
            .updateUserData(UserModel.fromJson(data));

        state = LoginStates.success(UserModel.fromJson(data));
        debugPrint("LOGIN RESPONSE SUCCESS:${response.success}");
      } else {
        debugPrint("LOGIN ERROR RESPONSE:$response");
        state = LoginStates.error(
          "The email or password you entered is incorrect. Please try again.",
        );
      }
    } catch (e, s) {
      debugPrint('LOGIN Error: $e, LOGIN StackTrace: $s');

      if (e is PlatformException && e.code == 'ERROR_INVALID_CREDENTIAL') {
        state = LoginStates.error(
          "The email or password you entered is incorrect. Please try again.",
          stackTrace: s,
        );
      } else if (e is PlatformException && e.code == 'ERROR_USER_NOT_FOUND') {
        state = LoginStates.error(
          "No account found with this email address. Please check your email or sign up for a new account.",
          stackTrace: s,
        );
      } else if (e is PlatformException && e.code == 'ERROR_WRONG_PASSWORD') {
        state = LoginStates.error(
          "The password you entered is incorrect. Please try again.",
          stackTrace: s,
        );
      } else {
        state = LoginStates.error(
          "An unexpected error occurred. Please try again later.",
          stackTrace: s,
        );
      }
    }
  }
}

typedef LoginStates = BaseState<UserModel>;

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginStates>(
  (ref) => LoginNotifier(LoginStates.initial(), ref),
);
