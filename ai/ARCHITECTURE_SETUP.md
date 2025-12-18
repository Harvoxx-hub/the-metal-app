# Clean Architecture Setup Guide

This document explains the Clean Architecture foundation that has been set up for migrating from SDK-based to API-based architecture.

## 📁 Structure Overview

The foundation follows Clean Architecture with three main layers:

```
lib/
├── core/                           # Core infrastructure
│   ├── network/                   # Network layer
│   │   ├── dio_client.dart        # HTTP client
│   │   ├── api_interceptor.dart   # Request/response interceptors
│   │   └── api_routes.dart        # API endpoint definitions (add your endpoints here)
│   ├── storage/                   # Storage layer
│   │   ├── shared_prefs_helper.dart
│   │   └── secure_storage_helper.dart
│   ├── di/                        # Dependency Injection
│   │   └── provider_setup.dart    # Core providers
│   └── error_handling/            # Error handling
│       ├── error_mapper.dart
│       └── error_handler.dart
│
├── domain/                        # Business Logic Layer
│   ├── entities/                  # Domain entities/DTOs
│   │   └── base_entity.dart
│   └── usecases/                  # Business use cases
│       └── base_usecase.dart
│
├── data/                          # Data Layer
│   ├── datasources/               # Data sources
│   │   ├── remote/                # Remote API data sources
│   │   └── local/                 # Local storage data sources
│   ├── repositories/              # Repository implementations
│   └── models/                    # Data models (API responses)
│
└── presentation/                  # UI Layer
    ├── views/                     # UI Screens
    ├── viewmodels/                # State management
    │   └── base_viewmodel.dart
    └── widgets/                   # Reusable components
```

## 🚀 Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

This will install the new `flutter_secure_storage` package.

### 2. Add Your API Endpoints

Edit `lib/core/network/api_routes.dart` and add your actual endpoints:

```dart
class ApiRoutes {
  static const String apiVersion = '/api/v1';

  // Add your endpoints here
  static const String login = '/auth/login';
  static const String getUserProfile = '/users/me';
  // ... etc
}
```

### 3. Create Your First Feature

Follow this pattern when implementing a new feature:

#### Step 1: Create Domain Entity
```dart
// lib/domain/entities/user_dto.dart
class UserDto extends BaseEntity {
  final String id;
  final String email;
  final String name;
  
  UserDto({required this.id, required this.email, required this.name});
}
```

#### Step 2: Create Data Model
```dart
// lib/data/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String name;
  
  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'],
        name = json['name'];
  
  UserDto toDomain() => UserDto(id: id, email: email, name: name);
}
```

#### Step 3: Create Remote Data Source
```dart
// lib/data/datasources/remote/auth_remote_data_source.dart
class AuthRemoteDataSource extends BaseRemoteDataSource {
  final DioClient dioClient;
  
  AuthRemoteDataSource(this.dioClient);
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dioClient.post(
      ApiRoutes.buildPath(ApiRoutes.login),
      data: {'email': email, 'password': password},
    );
    return response.data['data'];
  }
}
```

#### Step 4: Create Repository
```dart
// lib/data/repositories/auth/auth_repository.dart
class AuthRepository implements AuthRepositoryAbstract {
  final AuthRemoteDataSource remoteDataSource;
  
  AuthRepository(this.remoteDataSource);
  
  @override
  Future<BaseState<UserDto>> login(String email, String password) async {
    try {
      final data = await remoteDataSource.login(email, password);
      final user = UserModel.fromJson(data).toDomain();
      return BaseState.success(user);
    } catch (e) {
      return ErrorHandler.handleError<UserDto>(e);
    }
  }
}
```

#### Step 5: Create Use Case
```dart
// lib/domain/usecases/auth_usecase.dart
class LoginUseCase implements BaseUseCase<UserDto, LoginParams> {
  final AuthRepositoryAbstract repository;
  
  LoginUseCase(this.repository);
  
  @override
  Future<BaseState<UserDto>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;
  LoginParams({required this.email, required this.password});
}
```

#### Step 6: Create ViewModel
```dart
// lib/presentation/viewmodels/auth/login_viewmodel.dart
class LoginViewModel extends BaseViewModel<UserDto> {
  final LoginUseCase loginUseCase;
  
  LoginViewModel(this.loginUseCase);
  
  Future<void> login(String email, String password) async {
    setLoading();
    final result = await loginUseCase(LoginParams(email: email, password: password));
    if (result.isSuccess) {
      setSuccess(result.data!);
    } else {
      setError(result.errorMessage ?? 'Login failed');
    }
  }
}
```

#### Step 7: Create Provider
```dart
// lib/presentation/viewmodels/auth/login_viewmodel.dart (add at bottom)
final loginViewModelProvider = StateNotifierProvider<LoginViewModel, BaseState<UserDto>>((ref) {
  return LoginViewModel(
    LoginUseCase(
      AuthRepository(
        AuthRemoteDataSource(ref.read(dioClientProvider)),
      ),
    ),
  );
});
```

#### Step 8: Use in View
```dart
// lib/presentation/views/auth/login_page.dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginViewModelProvider);
    
    return ElevatedButton(
      onPressed: () {
        ref.read(loginViewModelProvider.notifier).login('email', 'password');
      },
      child: Text('Login'),
    );
  }
}
```

## 🔧 Core Components

### DioClient
The main HTTP client. Automatically handles:
- Base URL from `AppConfig`
- Authentication tokens via interceptor
- Request/response logging
- Error handling

### ApiInterceptor
Handles:
- Adding Authorization headers
- Token management
- Request/response logging

### Storage Helpers
- `SharedPrefsHelper`: For non-sensitive data
- `SecureStorageHelper`: For sensitive data (tokens, passwords)

### Error Handling
- `ErrorHandler`: Converts exceptions to `BaseState`
- `ErrorMapper`: Maps HTTP errors to user-friendly messages

## 📝 Next Steps

1. **As endpoints become available**, add them to `api_routes.dart`
2. **Implement features step by step** following the pattern above
3. **Migrate existing features** from SDK-based to API-based one at a time
4. **Test each feature** before moving to the next

## 🔄 Migration Strategy

When migrating an existing feature:

1. Keep the old implementation working
2. Create new API-based implementation alongside
3. Test the new implementation thoroughly
4. Switch over when ready
5. Remove old SDK-based code

This allows for gradual migration without breaking existing functionality.

