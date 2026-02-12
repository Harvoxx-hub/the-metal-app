#!/bin/bash

# Shorebird Android Push Script
# This script helps you create a new release or patch for Android on Shorebird

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current version from pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
BUILD_NUMBER=$(grep "^version:" pubspec.yaml | sed 's/version: //' | sed 's/.*+//')

echo -e "${BLUE}🚀 Shorebird Android Push${NC}"
echo -e "${BLUE}Current version: ${GREEN}${VERSION}+${BUILD_NUMBER}${NC}"
echo ""

# Check if flavor is provided as argument
FLAVOR=${1:-prod}

if [ "$FLAVOR" != "prod" ] && [ "$FLAVOR" != "dev" ]; then
    echo -e "${YELLOW}⚠️  Invalid flavor. Use 'prod' or 'dev'${NC}"
    echo "Usage: ./scripts/shorebird_push_android.sh [prod|dev] [release|patch]"
    exit 1
fi

# Check if type is provided as argument
TYPE=${2:-release}

if [ "$TYPE" != "release" ] && [ "$TYPE" != "patch" ]; then
    echo -e "${YELLOW}⚠️  Invalid type. Use 'release' or 'patch'${NC}"
    echo "Usage: ./scripts/shorebird_push_android.sh [prod|dev] [release|patch]"
    exit 1
fi

echo -e "${BLUE}Flavor: ${GREEN}${FLAVOR}${NC}"
echo -e "${BLUE}Type: ${GREEN}${TYPE}${NC}"
echo ""

if [ "$TYPE" == "release" ]; then
    echo -e "${YELLOW}📦 Creating a new Shorebird release for Android...${NC}"
    echo -e "${YELLOW}This will:${NC}"
    echo "  1. Build the Android app using Shorebird's Flutter fork"
    echo "  2. Upload the release to Shorebird servers"
    echo "  3. Create a version baseline for future patches"
    echo ""
    echo -e "${YELLOW}⚠️  Note: After creating a release, you still need to build and submit to Google Play Store as normal.${NC}"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    
    echo -e "${GREEN}Creating release...${NC}"
    shorebird release android --flavor "$FLAVOR" --build-name "$VERSION" --build-number "$BUILD_NUMBER"
    
    echo ""
    echo -e "${GREEN}✅ Release created successfully!${NC}"
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Build for Play Store: flutter build appbundle --release --flavor $FLAVOR"
    echo "  2. Upload the .aab file to Google Play Console"
    echo "  3. After approval, you can create patches using: ./scripts/shorebird_push_android.sh $FLAVOR patch"
    
elif [ "$TYPE" == "patch" ]; then
    echo -e "${YELLOW}🔧 Creating a Shorebird patch for Android...${NC}"
    echo -e "${YELLOW}This will:${NC}"
    echo "  1. Create a patch for Dart-only changes"
    echo "  2. Upload the patch to Shorebird servers"
    echo "  3. Distribute the patch OTA to users (if auto_update is enabled)"
    echo ""
    echo -e "${YELLOW}⚠️  Note: Patches only work for Dart code changes. Native code changes require a new release.${NC}"
    echo ""
    
    # Ask for release version to patch
    read -p "Enter the release version to patch (e.g., $VERSION, or 'latest'): " RELEASE_VERSION
    RELEASE_VERSION=${RELEASE_VERSION:-latest}
    
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    
    echo -e "${GREEN}Creating patch...${NC}"
    shorebird patch android --flavor "$FLAVOR" --release-version "$RELEASE_VERSION"
    
    echo ""
    echo -e "${GREEN}✅ Patch created successfully!${NC}"
    echo -e "${BLUE}The patch will be automatically distributed to users (if auto_update is enabled in shorebird.yaml)${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Done!${NC}"
