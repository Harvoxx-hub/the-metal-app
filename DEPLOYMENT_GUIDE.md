# 🚀 Deployment Guide

This guide covers deploying the Metal app to both Shorebird (OTA updates) and app stores (Google Play & App Store).

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Version Management](#version-management)
3. [Shorebird Deployment (OTA Updates)](#shorebird-deployment-ota-updates)
4. [App Store Deployment](#app-store-deployment)
5. [Deployment Workflows](#deployment-workflows)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Tools

- **Flutter SDK**: `>=3.0.3 <4.0.0`
- **Shorebird CLI**: Install via [official installer](https://docs.shorebird.dev/getting-started)
- **Xcode** (macOS): For iOS builds and App Store deployment
- **Android Studio**: For Android builds and Play Store deployment

### Required Accounts

- **Shorebird Account**: Sign up at [shorebird.dev](https://shorebird.dev)
- **Google Play Console**: For Android app distribution
- **Apple App Store Connect**: For iOS app distribution

### Shorebird Setup

```bash
# Install Shorebird CLI (if not already installed)
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash

# Verify installation
shorebird --version

# Login to Shorebird (first time only)
shorebird login
```

---

## Version Management

### Version Format

The app uses semantic versioning in `pubspec.yaml`:

```yaml
version: 1.0.29+87
#          ^    ^
#          |    └─ Build number (required for stores)
#          └────── Version name (required for stores)
```

- **Version Name** (`1.0.29`): User-visible version, should increment for store releases
- **Build Number** (`87`): Incremental build identifier, must increment for each store submission

### When to Increment Versions

| Change Type | Version Name | Build Number | Deployment Type |
|------------|--------------|--------------|-----------------|
| Dart-only bug fix | Same | Same | Shorebird Patch |
| New feature (Dart) | Same | Same | Shorebird Patch |
| Native code changes | **Increment** | **Increment** | Store Release |
| Plugin additions | **Increment** | **Increment** | Store Release |
| Asset changes | **Increment** | **Increment** | Store Release |
| Flutter version upgrade | **Increment** | **Increment** | Store Release |

---

## Shorebird Deployment (OTA Updates)

### Overview

Shorebird allows deploying Dart-only updates without going through app stores. Patches are delivered over-the-air (OTA) to users.

### Important Limitations

⚠️ **What CANNOT be patched via Shorebird:**
- Native code changes (Java/Kotlin, Objective-C/Swift)
- Plugin additions/updates (if they include native code)
- Asset files (images, fonts, etc.)
- Flutter engine version changes
- Changes to `pubspec.yaml` dependencies that include native code

✅ **What CAN be patched:**
- Dart code changes
- UI updates
- Bug fixes in Dart logic
- Business logic changes

### Initial Release (First Time Only)

Before creating patches, you must create a **release** using Shorebird. This becomes the baseline for all future patches.

#### For Android

```bash
# Navigate to project root
cd /path/to/metal

# Create a release for production flavor
shorebird release android --flavor prod

# Or for dev flavor
shorebird release android --flavor dev
```

**What this does:**
- Builds the Android app using Shorebird's Flutter fork
- Uploads the release to Shorebird servers
- Associates it with the app_id in `shorebird.yaml`
- Creates a version baseline for future patches

**Important:** After creating a release, you still need to build and submit to Google Play Store as normal. The Shorebird release is just the baseline for patches.

#### For iOS

```bash
# Create a release for production
shorebird release ios --flavor prod --codesign

# Or for dev flavor
shorebird release ios --flavor dev --codesign
```

**Note:** iOS releases require code signing certificates to be set up.

### Creating Patches

Once you have a release, you can create patches for Dart-only changes:

#### For Android

```bash
# Create a patch for production
shorebird patch android --flavor prod --release-version <version>

# Example: Patch for version 1.0.29
shorebird patch android --flavor prod --release-version 1.0.29

# Create a patch for dev
shorebird patch android --flavor dev --release-version <version>
```

#### For iOS

```bash
# Create a patch for production
shorebird patch ios --flavor prod --release-version <version> --codesign

# Example: Patch for version 1.0.29
shorebird patch ios --flavor prod --release-version 1.0.29 --codesign
```

### Patch Workflow

1. **Make your Dart code changes**
2. **Test locally** with `flutter run`
3. **Create patch** using `shorebird patch`
4. **Patch is automatically distributed** to users (if `auto_update: true`)
5. **Users receive patch** on next app launch (or resume if configured)

### Verifying Patches

```bash
# List all releases
shorebird releases list

# View patch status
shorebird patches list

# Check which patch version is currently deployed
shorebird releases promote --version <version> --channel <channel>
```

---

## App Store Deployment

### Google Play Store (Android)

#### 1. Prepare Release Build

```bash
# Build a release APK (for testing)
flutter build apk --release --flavor prod

# Or build App Bundle (required for Play Store)
flutter build appbundle --release --flavor prod
```

**Output:** `build/app/outputs/bundle/prodRelease/app-prod-release.aab`

#### 2. Create Release Using Shorebird (Recommended)

Before uploading to Play Store, create a Shorebird release:

```bash
shorebird release android --flavor prod
```

This ensures the app is ready for future patches.

#### 3. Upload to Play Store

1. **Open Google Play Console**: https://play.google.com/console
2. **Select your app**: Metal
3. **Go to Production** (or Internal/Alpha/Beta testing)
4. **Create new release**:
   - Upload the `.aab` file from step 1
   - Or use the one created by Shorebird (check `build/app/outputs/bundle/`)
5. **Fill release notes**
6. **Review and publish**

#### 4. Update Version in `pubspec.yaml`

After successful deployment, update version for next release:

```yaml
version: 1.0.30+88  # Increment both version and build number
```

### Apple App Store (iOS)

#### 1. Prepare Release Build

```bash
# Build iOS release (Archive)
flutter build ipa --release --flavor prod
```

**Or use Xcode:**

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Product → Archive**
3. Wait for build to complete

#### 2. Create Release Using Shorebird (Recommended)

```bash
shorebird release ios --flavor prod --codesign
```

#### 3. Upload to App Store Connect

**Via Xcode:**

1. **Window → Organizer**
2. **Select your archive**
3. **Distribute App**
4. **App Store Connect** → Next
5. **Upload** → Next
6. **Select options** (include bitcode, etc.)
7. **Upload** → Wait for processing

**Via Command Line:**

```bash
# Using fastlane (if configured)
fastlane ios release

# Or manually via Transporter app (macOS only)
# Download from Mac App Store
```

#### 4. Submit for Review in App Store Connect

1. **Open App Store Connect**: https://appstoreconnect.apple.com
2. **My Apps → Metal**
3. **Prepare for Submission**
4. **Select build** (from uploaded archives)
5. **Add app information** (screenshots, description, etc.)
6. **Submit for Review**

#### 5. Update Version in `pubspec.yaml`

After successful submission:

```yaml
version: 1.0.30+88  # Increment both version and build number
```

---

## Deployment Workflows

### Workflow 1: Dart-Only Bug Fix (Quick Patch)

**Use when:** Fixing bugs or making small changes to Dart code only.

```bash
# 1. Make your code changes
# 2. Test locally
flutter run --release --flavor prod

# 3. Create and deploy patch
shorebird patch android --flavor prod --release-version 1.0.29

# Done! Users get update OTA within hours
```

⏱️ **Time:** ~5-10 minutes  
📦 **Distribution:** Automatic OTA (hours)

### Workflow 2: New Feature (Store Release)

**Use when:** Adding new features, native code changes, or plugin updates.

```bash
# 1. Update version in pubspec.yaml
# version: 1.0.30+88

# 2. Create Shorebird release
shorebird release android --flavor prod
shorebird release ios --flavor prod --codesign

# 3. Build for stores
flutter build appbundle --release --flavor prod  # Android
flutter build ipa --release --flavor prod        # iOS

# 4. Upload to stores (Play Console / App Store Connect)
# 5. Submit for review

# 6. After approval, patches can be created against this release
```

⏱️ **Time:** 1-7 days (store review)  
📦 **Distribution:** App stores

### Workflow 3: Hotfix (Patch Existing Release)

**Use when:** Critical bug needs immediate fix without waiting for store review.

```bash
# 1. Fix the bug in Dart code
# 2. Create emergency patch
shorebird patch android --flavor prod --release-version 1.0.29

# 3. (Optional) Promote patch to all users immediately
shorebird releases promote --version 1.0.29 --channel stable --patch-number <patch_num>

# Users receive fix within hours instead of waiting for store review
```

⏱️ **Time:** ~30 minutes - 2 hours  
📦 **Distribution:** OTA (faster than stores)

---

## Best Practices

### 1. Always Create Shorebird Release Before Store Submission

```bash
# Recommended order:
shorebird release android --flavor prod    # 1. Create baseline
flutter build appbundle --release --flavor prod  # 2. Build for store
# 3. Upload to Play Store
```

This ensures you can patch the store version immediately after release.

### 2. Version Management

- **Never** create patches for a version that hasn't been released to stores yet
- **Always** increment build number for store releases
- **Keep** version names consistent between Shorebird releases and store builds

### 3. Testing

```bash
# Test patches locally before deploying
shorebird preview --release-version <version> --patch-number <patch>

# Or test with a release channel
shorebird releases promote --version <version> --channel preview
```

### 4. Release Channels

Use channels for staged rollouts:

```bash
# Promote to preview channel (beta testers)
shorebird releases promote --version 1.0.29 --channel preview --patch-number 1

# Promote to stable (all users)
shorebird releases promote --version 1.0.29 --channel stable --patch-number 1
```

### 5. Monitoring

- **Check patch adoption**: Use Shorebird dashboard
- **Monitor crash reports**: Check Sentry/Firebase Crashlytics
- **Track version distribution**: Use analytics (Firebase Analytics)

---

## Troubleshooting

### Common Issues

#### Issue: "No release found for version X"

**Solution:** You must create a Shorebird release before creating patches:

```bash
shorebird release android --flavor prod --release-version 1.0.29
```

#### Issue: "Patch failed: Engine version mismatch"

**Solution:** Patches must use the same Flutter/engine version as the release. Check Flutter version:

```bash
flutter --version
shorebird releases list  # Check release Flutter version
```

#### Issue: "Cannot patch: Native code changes detected"

**Solution:** Native code changes require a new store release, not a patch:

```bash
# Must create new release and submit to stores
shorebird release android --flavor prod
flutter build appbundle --release --flavor prod
# Upload to store
```

#### Issue: "Patch not applying to users"

**Check:**
1. `auto_update: true` in `shorebird.yaml`?
2. Users have internet connection?
3. Patch was successfully promoted?

```bash
# Check patch status
shorebird patches list

# Promote patch explicitly
shorebird releases promote --version <version> --channel stable
```

#### Issue: Build fails after Shorebird release

**Solution:** Make sure Shorebird CLI is up to date:

```bash
shorebird update
```

### Getting Help

- **Shorebird Docs**: https://docs.shorebird.dev
- **Shorebird Discord**: https://discord.gg/shorebird
- **Project README**: Check `README.md` for project-specific notes

---

## Quick Reference

### Common Commands

```bash
# Shorebird
shorebird release android --flavor prod          # Create release
shorebird patch android --flavor prod --release-version 1.0.29  # Create patch
shorebird releases list                          # List releases
shorebird patches list                           # List patches

# Flutter Build
flutter build appbundle --release --flavor prod  # Android bundle
flutter build ipa --release --flavor prod        # iOS archive
flutter build apk --release --flavor prod        # Android APK (testing)

# Testing
flutter run --release --flavor prod              # Run release build
shorebird preview --release-version 1.0.29       # Test patch locally
```

### Current Configuration

- **App ID (Dev)**: `619258ce-81a9-4c0c-b30f-e01cc91fa399`
- **App ID (Prod)**: `71cbbcc2-7d75-4fbe-9919-65c26ea12e22`
- **Auto-Update**: Enabled (patches download automatically)
- **Current Version**: Check `pubspec.yaml`

---

## Checklist

Before deploying, ensure:

- [ ] Version numbers updated in `pubspec.yaml`
- [ ] Code changes tested locally
- [ ] Changelog/release notes prepared
- [ ] Shorebird release created (for patches)
- [ ] Build artifacts generated
- [ ] Store metadata updated (screenshots, descriptions)
- [ ] Tested on physical devices
- [ ] Crash reporting configured
- [ ] Analytics tracking enabled

---

**Last Updated:** January 2025  
**Maintained By:** Development Team
