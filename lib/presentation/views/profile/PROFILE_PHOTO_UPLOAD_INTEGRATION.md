# Profile Photo Upload Integration Guide

This guide shows how to integrate profile photo upload functionality into EditProfileView or any profile-related view.

## Overview

Sprint 7 has implemented a complete profile enhancement system with:
- **Media Upload Infrastructure**: S3 presigned URL pattern
- **Profile Photo Upload**: Upload photo → Update profile → Update global state
- **Work Email Verification**: Complete flow with code verification

## How to Add Photo Upload to EditProfileView

### Step 1: Import Required Dependencies

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:metal/presentation/viewmodels/profile/profile_photo_viewmodel.dart';
```

### Step 2: Add State Variables

```dart
class _EditProfileViewState extends ConsumerState<EditProfileView> {
  File? _selectedPhoto;
  final ImagePicker _imagePicker = ImagePicker();

  // ... existing state
}
```

### Step 3: Add Photo Picker Method

```dart
Future<void> _pickProfilePhoto() async {
  try {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
    }
  } catch (e) {
    // Show error snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to pick image: $e')),
    );
  }
}
```

### Step 4: Add Upload Method

```dart
Future<void> _uploadProfilePhoto() async {
  if (_selectedPhoto == null) return;

  final viewModel = ref.read(profilePhotoViewModelProvider.notifier);

  final success = await viewModel.uploadProfilePhoto(
    photoFile: _selectedPhoto!,
    contentType: 'image/jpeg', // or detect from file
  );

  if (success && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo updated!')),
    );
    setState(() {
      _selectedPhoto = null; // Clear selection
    });
  }
}
```

### Step 5: Add UI Components

```dart
// Profile photo display with upload button
Widget _buildProfilePhotoSection() {
  final user = ref.watch(currentUserProvider);
  final photoState = ref.watch(profilePhotoViewModelProvider);

  return Column(
    children: [
      Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _selectedPhoto != null
                ? FileImage(_selectedPhoto!)
                : (user?.profilePhoto != null
                    ? NetworkImage(user!.profilePhoto!)
                    : null) as ImageProvider?,
            child: user?.profilePhoto == null && _selectedPhoto == null
                ? const Icon(Icons.person, size: 60)
                : null,
          ),
          if (photoState.isUploading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: photoState.isUploading ? null : _pickProfilePhoto,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
      const Gap(16),
      if (_selectedPhoto != null)
        PlainButton(
          buttonText: 'Upload Photo',
          loading: photoState.isUploading,
          onPressed: _uploadProfilePhoto,
        ),
      if (photoState.errorMessage != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            photoState.errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
    ],
  );
}
```

### Step 6: Add to Dependencies (pubspec.yaml)

If not already present:

```yaml
dependencies:
  image_picker: ^1.0.0  # Check for latest version
```

## Complete Upload Flow

1. **User selects photo** → `ImagePicker.pickImage()`
2. **Photo displayed locally** → `setState(() => _selectedPhoto = file)`
3. **User taps Upload** → `profilePhotoViewModel.uploadProfilePhoto()`
4. **ViewModel calls Repository** → `profileRepository.uploadProfilePhoto()`
5. **Repository calls RemoteDataSource** → `profileRemoteDataSource.uploadProfilePhoto()`
6. **RemoteDataSource:**
   - Uploads file via `mediaDataSource.uploadMedia()` → S3 presigned URL
   - Updates profile with photo URL → `PUT /api/v1/users/me`
7. **Repository returns updated UserDto** → Wrapped in BaseState
8. **ViewModel updates global user state** → `userStateProvider.notifier.fetchAndSetUser()`
9. **UI updates automatically** → All views watching `currentUserProvider` see new photo

## Architecture Benefits

- **Single Responsibility**: Each layer has one job
- **Testable**: Mock at any layer boundary
- **Type-Safe**: DTOs at domain, Models at data
- **Global State**: Profile updates propagate to entire app
- **Error Handling**: Centralized via ErrorHandler
- **Loading States**: Built into ViewModel state

## Testing the Integration

1. Run the app
2. Navigate to Edit Profile
3. Tap camera icon
4. Select a photo
5. Tap Upload Photo
6. Verify:
   - Loading indicator shows
   - Success message appears
   - Photo updates across app
   - Global user state updated

## API Requirements

Requires these endpoints (already implemented):
- `POST /api/v1/media/upload-url` - Get S3 presigned URL
- `PUT /api/v1/users/me` - Update profile with photo URL

## Common Issues

1. **Image too large**: Set `maxWidth`, `maxHeight`, `imageQuality` in ImagePicker
2. **Wrong content type**: Detect from file extension or use `lookupMimeType()`
3. **Photo not updating**: Check if `userStateProvider.fetchAndSetUser()` is called
4. **Upload fails**: Check S3 upload permissions and presigned URL expiry

## Work Email Verification Integration

To add work email verification to settings:

```dart
import 'package:metal/presentation/views/verification/work_email_verification_view.dart';

// In settings menu
ListTile(
  title: const Text('Verify Work Email'),
  subtitle: const Text('Get a professional badge'),
  leading: const Icon(Icons.verified_user),
  onPressed: () {
    Navigator.pushNamed(context, WorkEmailVerificationView.route);
  },
)
```

## Files Created in Sprint 7

### Data Layer
- `lib/data/datasources/remote/verification_remote_data_source.dart`
- `lib/data/datasources/remote/media_remote_data_source_provider.dart`
- `lib/data/repositories/verification/verification_repository_abstract.dart`
- `lib/data/repositories/verification/verification_repository.dart`
- `lib/data/repositories/verification/verification_repository_providers.dart`

### Presentation Layer
- `lib/presentation/viewmodels/profile/profile_photo_viewmodel.dart`
- `lib/presentation/viewmodels/verification/work_email_verification_viewmodel.dart`
- `lib/presentation/views/verification/work_email_verification_view.dart`

### Enhanced Files
- `lib/data/datasources/remote/profile_remote_data_source.dart` - Added `uploadProfilePhoto()`
- `lib/data/repositories/profile/profile_repository_abstract.dart` - Added `uploadProfilePhoto()`
- `lib/data/repositories/profile/profile_repository.dart` - Added `uploadProfilePhoto()`
- `lib/core/network/api_routes.dart` - Added work email verification endpoints

### Deleted Files
- `lib/features/profile/provider/upload.profile.image.notifier.dart`
- `lib/features/profile/provider/delete.user.notifier.dart`

## Next Steps

1. Integrate photo upload UI into EditProfileView
2. Add work email verification option to Settings
3. Test complete upload flow
4. Add loading/error states UI
5. Test edge cases (network failures, large files, etc.)

---

*Sprint 7 Complete - Profile Enhancement & Media Upload*
