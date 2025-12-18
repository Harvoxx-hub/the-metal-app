# Authentication Implementation Example

This document shows a complete example of how to use the Clean Architecture authentication implementation.

## 📁 File Structure

```
lib/
├── domain/
│   └── entities/
│       └── user_dto.dart                    # Domain entity
├── data/
│   ├── models/
│   │   └── user_model.dart                 # API response model
│   ├── datasources/
│   │   └── remote/
│   │       ├── auth_remote_data_source.dart
│   │       └── remote_data_source_providers.dart
│   └── repositories/
│       └── auth/
│           ├── auth_repository_abstract.dart
│           ├── auth_repository.dart
│           └── auth_repository_providers.dart
├── domain/
│   └── usecases/
│       ├── auth_usecase.dart
│       └── auth_usecase_providers.dart
└── presentation/
    └── viewmodels/
        └── auth/
            ├── login_viewmodel.dart
            └── login_viewmodel_providers.dart
```

## 🚀 Usage in a View

Here's how to use the login ViewModel in a Flutter widget:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/presentation/viewmodels/auth/login_viewmodel_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(loginViewModelProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              if (loginState.isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: Text('Login'),
                ),
              if (loginState.isError)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    loginState.errorMessage ?? 'An error occurred',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (loginState.isSuccess)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Login successful! Welcome ${loginState.data?.user.fullname ?? loginState.data?.user.email}',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 🔄 Data Flow

```
1. User taps "Login" button
   ↓
2. ViewModel.login() is called
   ↓
3. ViewModel calls LoginUseCase
   ↓
4. UseCase calls AuthRepository
   ↓
5. Repository calls AuthRemoteDataSource
   ↓
6. DataSource makes HTTP request via DioClient
   ↓
7. Response flows back:
   DataSource → Repository → UseCase → ViewModel → UI
```

## 🔑 Key Points

1. **State Management**: The ViewModel uses `BaseState<LoginResponseDto>` to manage loading, success, and error states
2. **Token Storage**: The authentication token is automatically stored in secure storage when login succeeds
3. **Error Handling**: Errors are automatically mapped to user-friendly messages via `ErrorHandler`
4. **Dependency Injection**: All dependencies are injected via Riverpod providers

## 📝 Next Steps

1. **Test the implementation** with your actual API endpoint
2. **Adjust the response parsing** in `UserModel.fromJson()` if your API response format differs
3. **Add signup flow** using `SignupUseCase` and `SignupViewModel` (similar pattern)
4. **Handle token refresh** when implementing token expiration logic
5. **Navigate to home screen** on successful login

## 🧪 Testing

You can test this implementation by:

1. Making sure your backend `/api/v1/auth/login` endpoint is available
2. The endpoint should return:
   ```json
   {
     "success": true,
     "data": {
       "token": "firebase-id-token",
       "user": {
         "id": "user-id",
         "email": "user@example.com",
         "fullname": "John Doe",
         ...
       },
       "expiresIn": 3600
     },
     "message": "Login successful"
   }
   ```

3. Update `UserModel.fromJson()` if your API response structure differs

