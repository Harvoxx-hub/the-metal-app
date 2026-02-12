#!/bin/bash

echo "Building for Production Environment..."

# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Build for iOS production
echo "Building for iOS Production..."
flutter build ios --flavor prod --dart-define=FLAVOR=prod

# Build for Android production
echo "Building for Android Production..."
flutter build apk --flavor prod --dart-define=FLAVOR=prod

echo "Production build completed!" 