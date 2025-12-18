# Splash & Onboarding Flow - Clean Architecture Implementation

## ✅ Implementation Complete

Clean Architecture implementations for splash and onboarding screens have been created.

## 📁 Files Created

### Splash Flow
- **Domain**: `lib/domain/usecases/auth_check_usecase.dart` - Checks if user is authenticated
- **ViewModel**: `lib/presentation/viewmodels/splash/splash_viewmodel.dart` - Manages splash state
- **Providers**: `lib/presentation/viewmodels/splash/splash_viewmodel_providers.dart` - DI setup
- **View**: `lib/presentation/views/splash/splash_view.dart` - Splash screen UI

### Onboarding Flow
- **ViewModel**: `lib/presentation/viewmodels/onboarding/onboarding_viewmodel.dart` - Manages onboarding state
- **Providers**: `lib/presentation/viewmodels/onboarding/onboarding_viewmodel_providers.dart` - DI setup
- **View**: `lib/presentation/views/onboarding/onboarding_view.dart` - Onboarding screen UI

## 🔄 Flow Logic

### Splash Screen Flow

```
1. App starts → SplashView loads
   ↓
2. Check if user has seen onboarding
   ↓
3a. If NO → Navigate to OnboardingView
   ↓
3b. If YES → Check authentication token
   ↓
4a. If token exists → User is authenticated → Navigate to Login (to get fresh user data)
   ↓
4b. If no token → User not authenticated → Navigate to OnboardingView
```

### Onboarding Screen Flow

```
1. User sees onboarding pages (3 pages with auto-scroll)
   ↓
2. User taps "Sign up" or "Log in"
   ↓
3. Mark onboarding as seen (saved to SharedPreferences)
   ↓
4. Navigate to appropriate screen (Signup/Login)
```

## 🎯 Key Features

### Splash View
- ✅ Checks authentication state using secure storage
- ✅ Checks if onboarding has been seen
- ✅ Automatic navigation based on state
- ✅ Loading indicator during checks
- ✅ Error handling with fallback to onboarding

### Onboarding View
- ✅ 3-page carousel with auto-scroll
- ✅ Page indicators (dots)
- ✅ Marks onboarding as seen when user interacts
- ✅ Navigation to signup/login
- ✅ Terms and privacy policy links

## 🔧 How It Works

### Authentication Check

The `AuthCheckUseCase` checks for stored authentication token:

```dart
// Checks secure storage for auth_token
final token = await secureStorage.getString('auth_token');
```

**Note**: Currently, it only checks if a token exists. In a full implementation, you might want to:
- Validate the token with the API
- Fetch user data if token is valid
- Handle token expiration

### Onboarding State

Onboarding state is stored in SharedPreferences:
- Key: `hasSeenOnboarding`
- Value: `bool`

When user interacts with onboarding (signup/login buttons), it's automatically marked as seen.

## 📝 Usage

### Update Routes

Add the new views to your routes:

```dart
// In routes.dart
case SplashView.route:
  return MaterialPageRoute(builder: (_) => const SplashView());

case OnboardingView.route:
  return MaterialPageRoute(builder: (_) => const OnboardingView());
```

### Update Initial Route

Set splash as the initial route:

```dart
// In main.dart or routes.dart
initialRoute: SplashView.route,
```

## 🔄 Migration from Old Implementation

The new implementation:
- ✅ Uses Clean Architecture pattern
- ✅ Uses API-based authentication (token in secure storage)
- ✅ Separates business logic from UI
- ✅ Uses dependency injection
- ✅ Maintains same UI/UX

### Differences

1. **Authentication Check**: 
   - Old: Uses Firebase Auth directly
   - New: Checks for stored token in secure storage

2. **State Management**:
   - Old: Uses Firebase Auth state + userStateProvider
   - New: Uses ViewModel with token check

3. **Onboarding Tracking**:
   - Old: Checked in dashboard
   - New: Tracked in splash and marked in onboarding

## 🚀 Next Steps

1. **Enhance Auth Check**: 
   - Add API call to validate token
   - Fetch user data if token is valid
   - Handle token refresh

2. **User Data Fetching**:
   - Create use case to fetch current user
   - Update splash to fetch and store user data
   - Navigate based on complete user state

3. **Testing**:
   - Test with no token (new user)
   - Test with valid token (returning user)
   - Test with expired token
   - Test onboarding flow

## 📚 Related Files

- Login View: `lib/presentation/views/auth/login_view.dart`
- Auth Use Cases: `lib/domain/usecases/auth_usecase.dart`
- Auth Repository: `lib/data/repositories/auth/auth_repository.dart`

## ✨ Benefits

- ✅ Clean separation of concerns
- ✅ Testable business logic
- ✅ Easy to modify navigation flow
- ✅ Consistent with Clean Architecture
- ✅ Ready for API-based authentication

The splash and onboarding flow is now ready and follows Clean Architecture principles! 🎉

