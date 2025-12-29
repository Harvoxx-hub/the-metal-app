# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Metal is a Flutter-based social networking/dating application that implements Clean Architecture principles with Riverpod for state management. The app features user discovery, real-time messaging, thoughts/posts, sparks (virtual currency), and user connections.

## Essential Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run code generation (for freezed, json_serializable, flutter_gen)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
flutter pub run build_runner watch --delete-conflicting-outputs

# Run the app
flutter run

# Run with specific flavor (dev/prod)
flutter run --flavor dev
flutter run --flavor prod

# Analyze code
flutter analyze

# Run tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Shorebird (OTA Updates)
The project uses Shorebird for over-the-air updates. Config is in `shorebird.yaml` with app IDs for dev and prod flavors.

```bash
# Create a release
shorebird release android --flavor prod

# Create a patch
shorebird patch android --flavor prod
```

## Architecture

### Clean Architecture Layers

**Domain Layer** (`lib/domain/`)
- `entities/` - DTOs (Data Transfer Objects) using plain Dart classes with `toJson()`/`fromJson()`
- `usecases/` - Business logic encapsulation (not consistently implemented)

**Data Layer** (`lib/data/`)
- `datasources/remote/` - Remote data sources organized by feature
- `repositories/` - Repository implementations organized by feature, extending `BaseRepository`
- `models/` - Additional model classes

**Presentation Layer** (`lib/presentation/`)
- `views/` - UI screens organized by feature
- `viewmodels/` - Riverpod-based state management (StateNotifier/AsyncNotifier patterns)
- `widgets/` - Reusable UI components specific to presentation

### Key Architectural Patterns

**State Management with Riverpod:**
- Uses `flutter_riverpod` for dependency injection and state management
- Providers are defined in `*_providers.dart` files within feature folders
- ViewModels extend `StateNotifier` or use `AsyncNotifier` patterns
- Core providers initialized in `lib/core/di/provider_setup.dart`
- `SharedPreferences` is initialized in `main.dart` and provided via override

**State Pattern:**
- All repository methods return `BaseState<T>` (see `lib/core/state/base.state.dart`)
- Status enum: `initial`, `loading`, `success`, `error`, `action`
- Automatically shows toast on error creation
- ViewModels consume `BaseState` and map to UI states

**Repository Pattern:**
- Each feature has a repository in `lib/data/repositories/<feature>/`
- Repositories implement `BaseRepository` or `BaseCrudRepository<T>`
- Repository providers defined in `<feature>_repository_providers.dart`

**Network Layer:**
- `DioClient` (`lib/core/network/dio_client.dart`) is the core HTTP client
- Uses `AuthInterceptor` for automatic token injection and refresh
- Interceptor handles 401s and token refresh automatically
- API routes centralized in `lib/core/network/api_routes.dart`
- Base URL configured in `AppConstants.apiUrl`

**WebSocket for Real-time:**
- `WebSocketService` (`lib/core/services/websocket_service.dart`) manages WebSocket connections
- Singleton pattern with auto-reconnection and heartbeat
- Used for real-time messaging and live updates
- Provider: `websocketServiceProvider` in `lib/core/services/websocket_provider.dart`

**Navigation:**
- Uses Flutter's traditional imperative navigation (Navigator)
- Routes defined in `lib/route/routes.dart` with `AppRoutes` class
- Global navigation key: `navKey` in `main.dart`
- Deep linking handled by `DeepLinkService` (`lib/core/services/deep_link_service.dart`)

**Storage:**
- `SecureStorageHelper` for sensitive data (tokens, credentials)
- `SharedPrefsHelper` for non-sensitive preferences
- Both provided via Riverpod providers in `lib/core/di/provider_setup.dart`

### Feature Organization

Each feature follows this structure:
```
lib/
├── data/
│   ├── datasources/remote/<feature>_remote_data_source.dart
│   ├── models/<feature>_*.dart
│   └── repositories/<feature>/
│       ├── <feature>_repository.dart
│       └── <feature>_repository_providers.dart
├── domain/
│   ├── entities/<feature>_dto.dart
│   └── usecases/<feature>_*.dart (optional)
└── presentation/
    ├── viewmodels/<feature>/
    │   ├── <feature>_viewmodel.dart
    │   └── <feature>_viewmodel_providers.dart
    └── views/<feature>/
        └── <feature>_view.dart
```

Major features: auth, profile, discovery, chat, thought, spark, community, notification, connection

## Key Files and Directories

### Core Infrastructure
- `lib/main.dart` - App entry point, Firebase/FCM initialization, lifecycle handler setup
- `lib/core/di/provider_setup.dart` - Core Riverpod providers (Dio, storage, etc.)
- `lib/core/network/dio_client.dart` - HTTP client with auth interceptor
- `lib/core/network/auth/auth_interceptor.dart` - Token injection and refresh logic
- `lib/core/network/api_routes.dart` - Centralized API endpoint definitions
- `lib/core/state/base.state.dart` - Standard state wrapper for all async operations
- `lib/core/services/websocket_service.dart` - Real-time WebSocket connection manager

### Configuration
- `lib/core/constants/app_constants.dart` - API URLs, app-wide constants
- `lib/firebase_options.dart` - Auto-generated Firebase config
- `shorebird.yaml` - OTA update configuration (dev/prod flavors)
- `assets/env/` - Environment-specific configs

### Resources
- `lib/res/` - Theme, colors, text styles
- `lib/gen/` - Auto-generated code (flutter_gen)
- `lib/widgets/` - Shared, reusable widgets across features

## Code Generation

This project uses code generation for:
- `freezed` - Immutable data classes (if used, check individual files)
- `json_serializable` - JSON serialization for DTOs
- `flutter_gen_runner` - Asset generation

Always run after modifying models/DTOs:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Firebase Integration

- **Firebase Core** - Initialized in `main.dart`
- **Firebase Messaging** - Push notifications via FCM (`lib/fcm/fcm_client.dart`)
- **Firebase Analytics** - User analytics tracking
- **Firebase Remote Config** - Feature flags and remote configuration (`lib/core/services/firebase.remote.config.service.dart`)
- **Cloud Functions** - Backend integration

Background message handler defined in `main.dart` as `_firebaseMessagingBackgroundHandler`.

## Current Development Context

The project is undergoing a refactor (branch: `refactor/phase1-rename-entities`):
- Renaming data models to follow DTO (Data Transfer Object) pattern
- Cleaning up deprecated code and unused dependencies
- Recent changes removed common.dart and timestamp_converter.dart utilities
- WebSocket service recently added for real-time features

## Important Patterns to Follow

1. **DTO Naming**: Domain entities should be named `*Dto` (e.g., `UserDto`, `MessageDto`)
2. **State Handling**: Always use `BaseState<T>` for repository returns
3. **Provider Naming**: Use `*Provider` suffix consistently, define in `*_providers.dart` files
4. **Error Handling**: Errors automatically show toast via `BaseState.error()` factory
5. **API Routes**: Add new endpoints to `ApiRoutes` class, not hardcoded strings
6. **Storage**: Use `SecureStorageHelper` for auth tokens, `SharedPrefsHelper` for preferences
7. **Repository Pattern**: Each feature should have its own repository extending `BaseRepository`

## Platform Support

- Primary platforms: iOS, Android
- Also configured for: Web, Windows, Linux, macOS
- iOS deployment target: See `ios/Podfile`
- Minimum Android SDK: 21

## Testing

Currently minimal test coverage (basic widget test exists in `test/widget_test.dart`). When adding tests:
- Place in `test/` directory mirroring `lib/` structure
- Use `flutter_test` package
- Run with `flutter test`
