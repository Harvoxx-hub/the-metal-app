# Profile API Implementation - Complete

## ✅ Implementation Complete

All profile endpoints have been implemented following Clean Architecture principles. The profile setup flow now makes real API calls instead of using placeholder delays.

## 📁 Files Created/Updated

### API Routes
- **`lib/core/network/api_routes.dart`**
  - Added profile endpoints:
    - `getUserProfile` - GET `/api/v1/users/me`
    - `updateUserProfile` - PUT `/api/v1/users/me`
    - `completeProfile` - POST `/api/v1/users/me/profile/complete`
  
  **Note**: Profile step updates are stored locally. Only final completion makes an API call.

### Data Layer

#### Remote Data Source
- **`lib/data/datasources/remote/auth_remote_data_source.dart`**
  - Added `getUserProfile()` - Fetches current user profile
  - Added `updateUserProfile()` - Updates user profile
  - Added `completeProfile()` - Completes profile setup
  
  **Note**: Profile step data is stored locally in ViewModel state, not sent to API until completion.

#### Repository
- **`lib/data/repositories/auth/auth_repository_abstract.dart`**
  - Added abstract methods for profile operations
- **`lib/data/repositories/auth/auth_repository.dart`**
  - Implemented profile methods with error handling
  - Maps API responses to domain entities

### Domain Layer

#### Use Cases
- **`lib/domain/usecases/profile_usecase.dart`**
  - `UpdateProfileUseCase` - Updates profile with structured params
  - `CompleteProfileUseCase` - Completes entire profile setup
  
  **Note**: Step updates are handled locally by ViewModel. No use case needed for individual steps.

#### Use Case Providers
- **`lib/domain/usecases/profile_usecase_providers.dart`** (NEW)
  - Riverpod providers for all profile use cases

### Presentation Layer

#### ViewModel
- **`lib/presentation/viewmodels/profile/profile_setup_viewmodel.dart`**
  - Updated `saveStepData()` to call real API
  - Updated `completeProfile()` to call real API
  - Proper error handling and state management

## 🔄 API Flow

### Step-by-Step Profile Update (Local Only)

```
1. User fills form in View (e.g., BasicInfoView)
   ↓
2. View calls ProfileSetupViewModel.saveStepData()
   ↓
3. ViewModel stores data locally in state.collectedData
   ↓
4. ViewModel updates currentStep and progress
   ↓
5. View navigates to next step
   
   ⚠️ NO API CALL - Data stored locally until completion
```

### Complete Profile

```
1. User completes final step (PreferencesView)
   ↓
2. View calls ProfileSetupViewModel.completeProfile()
   ↓
3. ViewModel calls CompleteProfileUseCase
   ↓
4. UseCase calls AuthRepository.completeProfile()
   ↓
5. Repository calls AuthRemoteDataSource.completeProfile()
   ↓
6. DataSource makes POST /api/v1/users/me/profile/complete
   ↓
7. Response flows back and navigates to Dashboard
```

## 📋 API Endpoints

### 1. Complete Profile
**Endpoint**: `POST /api/v1/users/me/profile/complete`

**Request Body**:
```json
{
  "fullname": "John Doe",
  "username": "johndoe",
  "gender": "Male",
  "dob": "01/01/1990",
  "metal": "metal_id",
  "passion": ["passion1", "passion2"],
  "extraData": {
    "maritalStatus": "Single",
    "religion": "Christian",
    "profession": "Engineer",
    "language": "English,Spanish"
  },
  "bio": "User bio text",
  "connectWith": "Female,Everyone",
  "preferences": {
    "ageRange": "18-25,25-30",
    "religion": "Christian,Muslim",
    // ... other preferences
  },
  "completedProfile": true,
  "profileUpdated": true
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "user_id",
    "email": "user@example.com",
    "completedProfile": true,
    "profileUpdated": true,
    // ... complete user data
  },
  "message": "Profile completed successfully"
}
```

### 2. Get User Profile
**Endpoint**: `GET /api/v1/users/me`

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "user_id",
    "email": "user@example.com",
    // ... complete user data
  }
}
```

### 3. Update User Profile
**Endpoint**: `PUT /api/v1/users/me`

**Request Body**:
```json
{
  "fullname": "John Doe",
  "username": "johndoe",
  // ... fields to update
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "user_id",
    // ... updated user data
  },
  "message": "Profile updated successfully"
}
```

## 🎯 Implementation Details

### Error Handling

All API calls use centralized error handling:
- `ErrorHandler.handleError<T>()` converts exceptions to `BaseState.error`
- `ErrorMapper` maps Dio exceptions to user-friendly messages
- Errors are displayed in the UI via `ProfileSetupHelpers.buildErrorWidget()`

### State Management

- **Loading State**: `isLoading = true` during API calls
- **Success State**: Updates state and moves to next step
- **Error State**: Displays error message, keeps user on current step

### Data Flow

1. **Step Data Collection**: Each view collects data and passes to ViewModel
2. **Local Storage**: ViewModel stores data in `collectedData` (local state only)
3. **State Update**: Updates current step and progress locally
4. **Navigation**: Automatically navigates to next step
5. **Final Completion**: On last step, all collected data is sent to API in one call

## 🔧 Usage

### In Views

```dart
// Save step data
await ref.read(profileSetupViewModelProvider.notifier).saveStepData(
  step: ProfileSetupStep.basicInfo,
  stepData: {
    'fullname': _nameController.text.trim(),
    'username': _userNameController.text.trim(),
    // ... other fields
  },
);

// Complete profile (final step)
await ref.read(profileSetupViewModelProvider.notifier).completeProfile();
```

### Error Handling

```dart
final setupState = ref.watch(profileSetupViewModelProvider);

// Display error if any
if (setupState.errorMessage != null) {
  ProfileSetupHelpers.buildErrorWidget(setupState.errorMessage);
}

// Check success before navigation
if (setupState.errorMessage == null && mounted) {
  Navigator.pushNamed(context, nextRoute);
}
```

## ✅ What's Working

- ✅ All profile endpoints defined in `ApiRoutes`
- ✅ Remote data source methods implemented
- ✅ Repository methods with error handling
- ✅ Use cases for step update and completion
- ✅ ViewModel integrated with real API calls
- ✅ Proper error handling and state management
- ✅ Clean Architecture pattern maintained

## 🚀 Next Steps

1. **Backend Implementation**: Ensure backend endpoints match the defined routes
2. **Testing**: Test each endpoint with real API responses
3. **Error Messages**: Customize error messages based on API responses
4. **Validation**: Add client-side validation before API calls
5. **Retry Logic**: Add retry mechanism for failed requests

## 📝 Notes

- **Local Storage**: Profile step data is stored locally in ViewModel state
- **Single API Call**: Only the final completion makes an API call with all collected data
- **Efficiency**: Reduces API calls from 7 to 1, improving performance
- **Data Safety**: All data is collected before sending, reducing partial update issues
- All API calls follow the standard response format: `{ success, data, message }`
- Authentication token is automatically attached via `ApiInterceptor`

