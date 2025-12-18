# Signup Flow - Clean Architecture Implementation

## ✅ Implementation Complete

Clean Architecture implementation for signup flow has been created.

## 📁 Files Created

### Signup Flow
- **ViewModel**: `lib/presentation/viewmodels/auth/signup_viewmodel.dart` - Manages signup state and FCM token
- **Providers**: `lib/presentation/viewmodels/auth/signup_viewmodel_providers.dart` - DI setup
- **View**: `lib/presentation/views/auth/signup_view.dart` - Signup screen UI

## 🔄 Flow Logic

### Signup Flow

```
1. User fills signup form (email, password, phone, referral code)
   ↓
2. User taps "Continue"
   ↓
3. ViewModel.signup() is called
   ↓
4. Initialize FCM token (for push notifications)
   ↓
5. Call SignupUseCase with user data + FCM token
   ↓
6. Repository makes API call to /api/v1/auth/signup
   ↓
7. API creates user and returns token + user data
   ↓
8. Store authentication token in secure storage
   ↓
9. Navigate to verification page
```

## 🎯 Key Features

### Signup View
- ✅ Form validation (email, password, phone)
- ✅ Phone number input with country code
- ✅ Optional referral code field
- ✅ FCM token initialization (automatic)
- ✅ Loading state during signup
- ✅ Error handling with toast notifications
- ✅ Automatic token storage
- ✅ Navigation to verification page on success

### Signup ViewModel
- ✅ Handles FCM token initialization
- ✅ Manages signup state (loading, success, error)
- ✅ Stores authentication token securely
- ✅ Error handling

## 📋 Form Fields

1. **Email** - Required, validated
2. **Password** - Required, validated (plain password)
3. **Phone Number** - Required, with country code picker
4. **Referral Code** - Optional

## 🔧 How It Works

### FCM Token Handling

The ViewModel automatically initializes FCM token before signup:

```dart
// Initialize FCM token
String? fcmToken;
try {
  fcmToken = await FCMClient.instance.init();
} catch (e) {
  // Continue with signup even if FCM fails
  fcmToken = null;
}
```

### Token Storage

After successful signup, the authentication token is stored:

```dart
await secureStorage.setString('auth_token', token);
```

### Navigation

On successful signup, user is navigated to verification page:

```dart
Navigator.pushReplacementNamed(
  context,
  AppRoutes.verificationPage,
  arguments: VerificationSentArgument(
    type: RouteFrom.AccountSetting,
    uuid: user.id,
    email: user.email,
  ),
);
```

## 📝 Usage

### Update Routes

Add the signup view to your routes:

```dart
// In routes.dart
case SignupView.route:
  return MaterialPageRoute(builder: (_) => const SignupView());
```

### Navigate to Signup

From onboarding or login page:

```dart
Navigator.pushNamed(context, SignupView.route);
// or
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SignupView()),
);
```

## 🔄 API Integration

The signup flow expects your API endpoint `/api/v1/auth/signup` to:

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "phoneNumber": "+1234567890",
  "referralCode": "123456",  // optional
  "fcmToken": "fcm-token-here"  // optional
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "firebase-id-token",
    "user": {
      "id": "user-id",
      "email": "user@example.com",
      "phone": "+1234567890",
      ...
    },
    "expiresIn": 3600
  },
  "message": "Signup successful"
}
```

## 🚀 Next Steps

1. **Test the signup flow** with your actual API endpoint
2. **Adjust response parsing** in `UserModel.fromJson()` if your API format differs
3. **Handle verification flow** after signup
4. **Add email validation** on the verification page

## 📚 Related Files

- Login View: `lib/presentation/views/auth/login_view.dart`
- Signup Use Case: `lib/domain/usecases/auth_usecase.dart` (SignupUseCase)
- Auth Repository: `lib/data/repositories/auth/auth_repository.dart`
- Auth Data Source: `lib/data/datasources/remote/auth_remote_data_source.dart`

## ✨ Benefits

- ✅ Clean separation of concerns
- ✅ Automatic FCM token handling
- ✅ Secure token storage
- ✅ Proper error handling
- ✅ Ready for API-based authentication
- ✅ Consistent with Clean Architecture

The signup flow is now complete and ready to use! 🎉

