import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/authentication/presentation/login/provider/login.state.dart';

class LoginProvider extends StateNotifier<LoginState> {
  LoginProvider() : super(LoginState.initial());

  Future<void> login(String username, String password) async {
    try {
      // Set loading state
      state = LoginState.loading();

      // Simulate an API request
      await Future.delayed(Duration(seconds: 2));

      // Simulate a successful login
      state = LoginState.success();
    } catch (e) {
      // Handle errors, e.g., incorrect credentials
      state = LoginState.error('Invalid username or password.');
    }
  }
}
