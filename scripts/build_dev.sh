#!/bin/bash

echo "Building for Development Environment..."

# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Build for iOS development
echo "Building for iOS Development..."
flutter build ios --flavor dev --dart-define=FLAVOR=dev

# Build for Android development
echo "Building for Android Development..."
flutter build apk --flavor dev --dart-define=FLAVOR=dev

echo "Development build completed!" 