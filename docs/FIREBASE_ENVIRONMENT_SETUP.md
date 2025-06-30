# Firebase Environment Setup Guide

## Overview
This project uses **two separate Firebase projects** to maintain complete isolation between development and production environments.

## Firebase Projects

### 🚀 Production Environment
- **Project ID:** `metal-ad87d`
- **Project Number:** `266202752447`
- **Android Package:** `com.bwh.metal_app`
- **iOS Bundle ID:** `com.bwh.metal`
- **Storage Bucket:** `metal-ad87d.firebasestorage.app`

### 🛠️ Development Environment
- **Project ID:** `metal-dev-bd058`
- **Project Number:** `325989388499`
- **Android Package:** `com.bwh.metal_app.dev`
- **iOS Bundle ID:** `com.bwh.metal.dev`
- **Storage Bucket:** `metal-dev-bd058.firebasestorage.app`

## Configuration Files

### Android Configuration
```
android/app/src/
├── dev/
│   └── google-services.json     # Development Firebase config
└── prod/
    └── google-services.json     # Production Firebase config
```

### iOS Configuration
```
ios/config/
├── dev/
│   └── GoogleService-Info.plist # Development Firebase config
└── prod/
    └── GoogleService-Info.plist # Production Firebase config
```

### Dart Configuration
```
lib/
├── firebase_options.dart        # Production Firebase options
└── firebase_options_dev.dart    # Development Firebase options
```

## Running the App

### Development Environment
```bash
# Using VS Code
# Select "development" configuration and run

# Using command line
flutter run --flavor dev --dart-define=FLAVOR=dev

# Using build script
./scripts/build_dev.sh
```

### Production Environment
```bash
# Using VS Code
# Select "production" configuration and run

# Using command line
flutter run --flavor prod --dart-define=FLAVOR=prod

# Using build script
./scripts/build_prod.sh
```

## Firebase Services Configuration

### Firestore
- **Production:** `metal-ad87d` project
- **Development:** `metal-dev-bd058` project

### Authentication
- **Production:** `metal-ad87d` project
- **Development:** `metal-dev-bd058` project

### Cloud Functions
- **Production:** `metal-ad87d` project
- **Development:** `metal-dev-bd058` project

### Storage
- **Production:** `metal-ad87d.firebasestorage.app`
- **Development:** `metal-dev-bd058.firebasestorage.app`

### Cloud Messaging
- **Production:** `metal-ad87d` project
- **Development:** `metal-dev-bd058` project

## Environment Detection

The app automatically detects the environment using:
```dart
const environment = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
```

## Testing Firebase Connection

The app includes a Firebase test service that runs on startup:
- Verifies Firebase initialization
- Tests Firestore connection
- Tests Authentication connection
- Prints environment information

Check the debug console for Firebase test results when the app starts.

## Security Rules

### Firestore Rules
Make sure to set up appropriate security rules for both environments:

**Development:**
```javascript
// More permissive for development
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // For development only
    }
  }
}
```

**Production:**
```javascript
// Strict security rules for production
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Storage Rules
Set up appropriate storage rules for both environments as well.

## Troubleshooting

### Common Issues

1. **Wrong Firebase Project Connected**
   - Check the debug console for Firebase test results
   - Verify the project ID matches your environment

2. **Configuration Files Missing**
   - Ensure `google-services.json` and `GoogleService-Info.plist` files are in the correct locations
   - Verify bundle IDs match your Firebase app configuration

3. **Build Configuration Issues**
   - Make sure you're using the correct flavor: `--flavor dev` or `--flavor prod`
   - Verify the `--dart-define=FLAVOR=dev` or `--dart-define=FLAVOR=prod` argument

### Verification Steps

1. Run the app in development mode
2. Check the debug console for Firebase test results
3. Verify the project ID shows `metal-dev-bd058`
4. Run the app in production mode
5. Verify the project ID shows `metal-ad87d`

## Best Practices

1. **Never use production Firebase in development**
2. **Keep development data separate from production**
3. **Use different API keys and configurations**
4. **Test both environments regularly**
5. **Monitor Firebase usage in both projects**
6. **Set up proper security rules for each environment**

## Firebase Console Access

- **Production Console:** https://console.firebase.google.com/project/metal-ad87d
- **Development Console:** https://console.firebase.google.com/project/metal-dev-bd058

Make sure you have appropriate access permissions for both projects. 