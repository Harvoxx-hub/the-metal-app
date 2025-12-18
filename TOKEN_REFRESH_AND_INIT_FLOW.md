# Token Refresh and App Initialization Flow

## Summary of Current Implementation Status

### ✅ 1. Token Refresh Flow
**Status**: Implemented in `api_interceptor.dart`

- **Automatic Token Refresh**: When a 401 error occurs, the interceptor automatically attempts to refresh the token
- **Refresh Token Storage**: Stores both `auth_token` and `refresh_token` in secure storage
- **Request Queuing**: Pending requests are queued during token refresh to prevent multiple refresh calls
- **Error Handling**: If refresh fails, tokens are cleared and user is logged out

**Implementation Details**:
- Token refresh happens automatically in `ApiInterceptor.onError()`
- Uses `AuthRemoteDataSource.refreshToken()` method
- Stores new tokens in `SecureStorageHelper`
- Retries failed requests with new token

**Missing**: 
- Need to store `refreshToken` from login/signup response
- Need to update `ApiInterceptor` to accept `AuthRemoteDataSource` (currently has circular dependency issue)

### ❌ 2. Profile Fetch After Signup
**Status**: NOT Implemented

**Current Flow**:
- Signup → Store token → Navigate to verification
- **Missing**: Fetch user profile after signup

**Needs**: Update `signup_view.dart` to fetch profile after successful signup

### ❌ 3. Profile Fetch on Splash/Dashboard Entry
**Status**: NOT Implemented

**Current Flow**:
- Splash checks if token exists → Navigates to login (even if authenticated)
- **Missing**: Fetch user profile when authenticated and navigate to dashboard

**Needs**: 
- Update `splash_view.dart` to fetch profile when authenticated
- Update `AuthCheckUseCase` to fetch user profile if token exists

### ❌ 4. App Initialization Provider
**Status**: NOT Implemented

**Current Approach**: Providers are lazy-loaded (called when needed)

**Recommendation**: 
- **Best Practice**: Use lazy loading (current approach) ✅
- **Alternative**: Create an `AppInitializationProvider` that:
  - Checks authentication on app start
  - Fetches user profile if authenticated
  - Initializes other required data
  - This can be called from splash screen or main app widget

## Recommended Implementation Strategy

### Option A: Lazy Loading (Current - Recommended) ✅
**Pros**:
- Faster app startup
- Only loads what's needed
- Better memory management
- Follows Riverpod best practices

**Cons**:
- Profile might not be immediately available
- Need to handle loading states

**Implementation**:
- Keep current lazy loading approach
- Fetch profile when needed (after login, on dashboard entry, etc.)
- Use `ProfileViewModel` to maintain state throughout app

### Option B: App Initialization Provider
**Pros**:
- All data ready on app start
- Single point of initialization
- Easier to track initialization state

**Cons**:
- Slower app startup
- Loads data even if not needed
- More complex error handling

**Implementation**:
```dart
final appInitializationProvider = FutureProvider<AppInitState>((ref) async {
  // Check auth
  // Fetch profile if authenticated
  // Initialize other services
  return AppInitState(...);
});
```

## Action Items

1. **Fix Token Refresh**:
   - Store `refreshToken` from login/signup responses
   - Fix circular dependency in `ApiInterceptor`
   - Test token refresh flow

2. **Add Profile Fetch After Signup**:
   - Update `signup_view.dart` to call `profileViewModelProvider.notifier.fetchUserProfile()` after signup

3. **Add Profile Fetch on Splash**:
   - Update `AuthCheckUseCase` to fetch profile if token exists
   - Or update `splash_view.dart` to fetch profile when authenticated

4. **Decide on Initialization Strategy**:
   - Recommend: Keep lazy loading, fetch profile when needed
   - Alternative: Create app initialization provider if needed

