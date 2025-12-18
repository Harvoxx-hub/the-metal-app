# Invoicer Architecture Documentation

## Table of Contents
1. [File Structure](#file-structure)
2. [Architecture Overview](#architecture-overview)
3. [Layer Breakdown](#layer-breakdown)
4. [Data Flow](#data-flow)
5. [Dependency Injection (DI)](#dependency-injection-di)
6. [Example: Authentication Flow](#example-authentication-flow)

---

## File Structure

```
lib/
├── main.dart                          # App entry point with ProviderScope
├── app.dart                           # Root app widget
├── app_config.dart                    # App configuration
│
├── core/                              # Core utilities and infrastructure
│   ├── constants/                     # App constants, strings, URLs, keys
│   ├── di/                            # Dependency Injection setup
│   │   └── provider_setup.dart        # Core providers (DioClient, Firebase, etc.)
│   ├── error_handling/                # Error handling, mappers, handlers
│   ├── navigation/                    # Navigation service
│   ├── network/                       # Network layer
│   │   ├── dio_client.dart            # HTTP client with interceptors
│   │   ├── api_routes.dart            # API endpoint definitions
│   │   └── api_interceptor.dart       # Request/response interceptors
│   ├── router/                        # App routing configuration
│   ├── services/                      # Core services (auth, notifications, etc.)
│   ├── storage/                       # Local storage (SharedPrefs, SecureStorage)
│   ├── themes/                        # App theming (colors, text styles)
│   └── utils/                         # Utility functions, helpers, validators
│
├── presentation/                      # UI Layer (Views & ViewModels)
│   ├── views/                         # UI Screens/Pages
│   │   ├── auth/                      # Authentication screens
│   │   ├── home/                      # Home/dashboard screens
│   │   ├── sales/                     # Sales screens
│   │   ├── product_management/        # Product management screens
│   │   ├── stores/                    # Store management screens
│   │   ├── profile/                   # Profile screens
│   │   └── ...
│   ├── viewmodels/                    # State management (Riverpod StateNotifiers)
│   │   ├── auth/                      # Auth view models
│   │   ├── business/                  # Business logic view models
│   │   ├── sales/                     # Sales view models
│   │   └── ...
│   └── widgets/                       # Reusable UI components
│
├── domain/                            # Business Logic Layer
│   ├── entities/                      # Domain entities/DTOs
│   │   ├── user_dto.dart
│   │   ├── business_types.dart
│   │   └── ...
│   └── usecases/                       # Business use cases
│       ├── auth_usecase.dart           # Authentication use cases
│       ├── business_usecase.dart       # Business operations
│       ├── product_usecase.dart        # Product operations
│       └── ...
│
└── data/                              # Data Layer
    ├── datasources/                   # Data sources
    │   ├── local/                     # Local data sources (SharedPrefs, etc.)
    │   │   └── auth_local_data_source.dart
    │   └── remote/                    # Remote data sources (API calls)
    │       ├── auth_remote_data_source.dart
    │       ├── business_remote_data_source.dart
    │       └── ...
    ├── repositories/                  # Repository implementations
    │   ├── auth/
    │   │   ├── auth_repository_abstract.dart  # Interface
    │   │   └── auth_repository.dart           # Implementation
    │   ├── business/
    │   └── ...
    └── models/                        # Data models (Firestore, API responses)
        ├── user_model.dart
        ├── business/
        └── ...
```

---

## Architecture Overview

The application follows **Clean Architecture** principles with a clear separation of concerns across three main layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (Views, ViewModels, Widgets)                               │
│  - UI Components                                             │
│  - State Management (Riverpod StateNotifiers)               │
│  - User Interactions                                         │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Uses
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  (UseCases, Entities)                                       │
│  - Business Logic                                            │
│  - Use Cases                                                 │
│  - Domain Entities/DTOs                                      │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Uses
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│  (Repositories, DataSources, Models)                        │
│  - Repository Implementations                                │
│  - Remote Data Sources (API)                                │
│  - Local Data Sources (Storage)                             │
│  - Data Models                                               │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Communicates with
                        ▼
            ┌───────────────────────┐
            │   External Services   │
            │  - Firebase (Auth, FS) │
            │  - Backend API         │
            │  - Local Storage      │
            └───────────────────────┘
```

---

## Layer Breakdown

### 1. Presentation Layer (`lib/presentation/`)

**Purpose**: Handles all UI-related code and user interactions.

**Components**:
- **Views** (`views/`): Flutter widgets representing screens/pages
- **ViewModels** (`viewmodels/`): State management using Riverpod `StateNotifier`
- **Widgets** (`widgets/`): Reusable UI components

**Responsibilities**:
- Display data to users
- Handle user input
- Manage UI state
- Navigate between screens
- Call use cases to perform business operations

**Example**:
```dart
// lib/presentation/viewmodels/auth/login_viewmodel.dart
class LoginViewModel extends StateNotifier<LoginState> {
  final AuthUseCase authUseCase;
  
  Future<void> login(String email, String password) async {
    state = LoginState.loading();
    final user = await authUseCase.loginWithApi(...);
    state = user;
  }
}
```

---

### 2. Domain Layer (`lib/domain/`)

**Purpose**: Contains business logic independent of external frameworks.

**Components**:
- **UseCases** (`usecases/`): Encapsulate business operations
- **Entities** (`entities/`): Domain objects/DTOs

**Responsibilities**:
- Define business rules
- Orchestrate data operations
- Transform data between layers
- Independent of UI and data sources

**Example**:
```dart
// lib/domain/usecases/auth_usecase.dart
class AuthUseCase {
  final AuthRepositoryAbstract authRepository;
  
  Future<BaseState<Map<String, dynamic>>> loginWithApi({
    required String email,
    required String password,
    ...
  }) async {
    return await authRepository.loginWithApi(...);
  }
}
```

---

### 3. Data Layer (`lib/data/`)

**Purpose**: Handles data operations and external service communication.

**Components**:
- **Repositories** (`repositories/`): Implement repository interfaces, coordinate data sources
- **DataSources** (`datasources/`): Direct data access (remote API, local storage)
- **Models** (`models/`): Data models for API/Firestore responses

**Responsibilities**:
- Make API calls
- Access local storage
- Transform API models to domain entities
- Handle data caching
- Error handling and mapping

**Example**:
```dart
// lib/data/repositories/auth/auth_repository.dart
class AuthRepository implements AuthRepositoryAbstract {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  
  Future<BaseState<Map<String, dynamic>>> loginWithApi(...) async {
    final response = await _remoteDataSource.login(...);
    // Transform and return
  }
}
```

---

## Data Flow

### Request Flow (User Action → Backend)

```
1. User Interaction (View)
   └─> User taps "Login" button
       │
2. ViewModel
   └─> login_viewmodel.dart: login(email, password)
       │
3. UseCase
   └─> auth_usecase.dart: loginWithApi(...)
       │
4. Repository
   └─> auth_repository.dart: loginWithApi(...)
       │
5. DataSource
   └─> auth_remote_data_source.dart: login(...)
       │
6. Network Client
   └─> dio_client.dart: post('/api/auth/login', ...)
       │
7. Backend API
   └─> POST /api/auth/login
```

### Response Flow (Backend → UI Update)

```
1. Backend API Response
   └─> { "user": {...}, "token": "..." }
       │
2. DataSource
   └─> auth_remote_data_source.dart: Returns Map<String, dynamic>
       │
3. Repository
   └─> auth_repository.dart: Wraps in BaseState<Map<String, dynamic>>
       │
4. UseCase
   └─> auth_usecase.dart: Returns BaseState<Map<String, dynamic>>
       │
5. ViewModel
   └─> login_viewmodel.dart: Updates state = LoginState.success(data)
       │
6. View (UI Update)
   └─> login_page.dart: ConsumerWidget rebuilds with new state
```

---

## Dependency Injection (DI)

### Role of Dependency Injection

Dependency Injection (DI) using **Riverpod** enables:
- **Loose Coupling**: Components depend on abstractions, not concrete implementations
- **Testability**: Easy to mock dependencies for unit testing
- **Maintainability**: Changes to implementations don't affect dependent code
- **Single Responsibility**: Each component focuses on its specific role

### DI Setup Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                    Core Providers                            │
│  (lib/core/di/provider_setup.dart)                          │
│  - dioClientProvider                                         │
│  - firebaseAuthProvider                                      │
│  - firebaseStorageProvider                                   │
│  - sharedPrefsHelperProvider                                 │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Used by
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              DataSource Providers                            │
│  (lib/data/datasources/remote/*.dart)                       │
│  - authRemoteDataSourceProvider                              │
│  - businessRemoteDataSourceProvider                          │
│  - productRemoteDataSourceProvider                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Used by
                        ▼
┌─────────────────────────────────────────────────────────────┐
│            Repository Providers                              │
│  (lib/data/repositories/*/*.dart)                            │
│  - authRepositoryProvider                                    │
│  - businessRepositoryProvider                                │
│  - productRepositoryProvider                                 │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Used by
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              UseCase Providers                               │
│  (lib/domain/usecases/*.dart)                               │
│  - authUseCaseProvider                                       │
│  - businessUseCaseProvider                                   │
│  - productUseCaseProvider                                    │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Used by
                        ▼
┌─────────────────────────────────────────────────────────────┐
│            ViewModel Providers                              │
│  (lib/presentation/viewmodels/*/*.dart)                    │
│  - loginViewModelProvider                                    │
│  - signupViewModelProvider                                   │
│  - productsViewModelProvider                                 │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Used by
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    Views (UI)                               │
│  (lib/presentation/views/*.dart)                           │
│  - ConsumerWidget / ConsumerStatefulWidget                  │
└─────────────────────────────────────────────────────────────┘
```

### Provider Registration Examples

#### 1. Core Providers
```dart
// lib/core/di/provider_setup.dart
final dioClientProvider = Provider((ref) => DioClient());
final firebaseAuthProvider = Provider((ref) => FirebaseAuthRepo());
final firebaseStorageProvider = Provider((ref) => FirebaseStorageRepoImpl());
final sharedPrefsHelperProvider = Provider((ref) => SharedPrefsHelper());
```

#### 2. DataSource Providers
```dart
// lib/data/datasources/remote/auth_remote_data_source.dart
final authRemoteDataSourceProvider = Provider((ref) {
  return AuthRemoteDataSource(
    ref.read(dioClientProvider),
    ref.read(firebaseAuthProvider),
    ref.read(firebaseStorageProvider),
  );
});
```

#### 3. Repository Providers
```dart
// lib/data/repositories/auth/auth_repository.dart
final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    ref.read(authRemoteDataSourceProvider),
    ref.read(authLocalDataSourceProvider),
  );
});
```

#### 4. UseCase Providers
```dart
// lib/domain/usecases/auth_usecase.dart
final authUseCaseProvider = Provider((ref) {
  return AuthUseCase(
    ref.read(authRepositoryProvider),
    ref.read(profileRepositoryProvider),
    ref.read(businessRepositoryProvider),
  );
});
```

#### 5. ViewModel Providers
```dart
// lib/presentation/viewmodels/auth/login_viewmodel.dart
final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel(
    ref,
    ref.read(authUseCaseProvider),
    ref.read(profileUseCaseProvider),
  );
});
```

#### 6. Usage in Views
```dart
// lib/presentation/views/auth/login_page.dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginViewModelProvider);
    
    return ElevatedButton(
      onPressed: () {
        ref.read(loginViewModelProvider.notifier).login(email, password);
      },
      child: Text('Login'),
    );
  }
}
```

---

## Example: Authentication Flow

### Complete Flow with DI

```
┌─────────────────────────────────────────────────────────────┐
│ 1. UI Layer: login_page.dart                                │
│    User enters credentials and taps "Login"                 │
│    └─> ref.read(loginViewModelProvider.notifier).login(...) │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. ViewModel: login_viewmodel.dart                          │
│    - Receives: email, password                              │
│    - Updates state to loading                               │
│    - Calls: authUseCase.loginWithApi(...)                   │
│    └─> DI: authUseCaseProvider injected via constructor     │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. UseCase: auth_usecase.dart                               │
│    - Orchestrates login flow                                │
│    - Calls: authRepository.loginWithApi(...)                │
│    └─> DI: authRepositoryProvider injected via constructor  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Repository: auth_repository.dart                         │
│    - Coordinates remote and local data sources              │
│    - Calls: authRemoteDataSource.login(...)                 │
│    - Handles error mapping                                  │
│    └─> DI: authRemoteDataSourceProvider injected           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. DataSource: auth_remote_data_source.dart                 │
│    - Makes HTTP request via DioClient                       │
│    - Calls: dioClient.post('/api/auth/login', ...)          │
│    └─> DI: dioClientProvider injected                       │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Network: dio_client.dart                                 │
│    - Adds interceptors (auth headers, logging)              │
│    - Makes HTTP POST request                                │
│    - Returns response data                                  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. Backend API: /api/auth/login                             │
│    - Validates credentials                                  │
│    - Returns user data and tokens                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Response flows back up
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ Response Path: Backend → DataSource → Repository →         │
│                UseCase → ViewModel → UI                     │
│                                                             │
│ - DataSource returns Map<String, dynamic>                   │
│ - Repository wraps in BaseState<Map<String, dynamic>>      │
│ - UseCase returns BaseState                                 │
│ - ViewModel updates state = LoginState.success(data)       │
│ - UI rebuilds with new state                                │
└─────────────────────────────────────────────────────────────┘
```

### Key DI Benefits in This Flow

1. **Testability**: Each layer can be tested independently by mocking dependencies
   ```dart
   // Test ViewModel with mocked UseCase
   final mockAuthUseCase = MockAuthUseCase();
   final viewModel = LoginViewModel(ref, mockAuthUseCase, ...);
   ```

2. **Flexibility**: Easy to swap implementations
   ```dart
   // Switch from API to mock data source
   final authRemoteDataSourceProvider = Provider((ref) => MockAuthRemoteDataSource());
   ```

3. **Single Source of Truth**: Providers ensure only one instance is created
   ```dart
   // Same DioClient instance used across all data sources
   ref.read(dioClientProvider) // Always returns same instance
   ```

4. **Lazy Initialization**: Providers are created only when first accessed
   ```dart
   // Provider not created until first ref.read() or ref.watch()
   ```

---

## Summary

### Architecture Principles

1. **Separation of Concerns**: Each layer has a single, well-defined responsibility
2. **Dependency Inversion**: High-level modules depend on abstractions, not implementations
3. **Single Responsibility**: Each class/component has one reason to change
4. **Testability**: Dependencies are injected, making unit testing straightforward

### Data Flow Pattern

```
UI → ViewModel → UseCase → Repository → DataSource → Network/Storage
```

### DI Pattern

```
ProviderScope (main.dart)
  └─> Core Providers
      └─> DataSource Providers
          └─> Repository Providers
              └─> UseCase Providers
                  └─> ViewModel Providers
                      └─> Views (ConsumerWidget)
```

### Key Technologies

- **State Management**: Riverpod (StateNotifierProvider, Provider)
- **Network**: Dio (HTTP client)
- **Backend**: Firebase (Auth, Firestore) + Custom API
- **Local Storage**: SharedPreferences, SecureStorage
- **Architecture**: Clean Architecture (Presentation → Domain → Data)

---

## Notes

- All providers are registered at the module level (file where they're defined)
- `ProviderScope` wraps the entire app in `main.dart` to enable Riverpod
- ViewModels use `StateNotifier` for state management
- Repositories implement abstract interfaces for testability
- UseCases orchestrate business logic and coordinate multiple repositories
- DataSources handle direct communication with external services


