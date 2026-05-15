#!/bin/bash

# Shorebird Android Push Script (Android only — iOS uses standard flutter build ipa)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
BUILD_NUMBER=$(grep "^version:" pubspec.yaml | sed 's/version: //' | sed 's/.*+//')

echo -e "${BLUE}🚀 Shorebird Android Push${NC}"
echo -e "${BLUE}Current version: ${GREEN}${VERSION}+${BUILD_NUMBER}${NC}"
echo ""

TYPE=${1:-release}

if [ "$TYPE" != "release" ] && [ "$TYPE" != "patch" ]; then
    echo -e "${YELLOW}⚠️  Invalid type. Use 'release' or 'patch'${NC}"
    echo "Usage: ./scripts/shorebird_push_android.sh [release|patch]"
    exit 1
fi

echo -e "${BLUE}Type: ${GREEN}${TYPE}${NC}"
echo ""

if [ "$TYPE" == "release" ]; then
    echo -e "${YELLOW}📦 Creating a new Shorebird release for Android...${NC}"
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    shorebird release android --build-name "$VERSION" --build-number "$BUILD_NUMBER"

    echo ""
    echo -e "${GREEN}✅ Release created successfully!${NC}"
    echo -e "${BLUE}Next: upload the app bundle to Google Play Console.${NC}"

elif [ "$TYPE" == "patch" ]; then
    read -p "Enter the release version to patch (e.g., $VERSION): " RELEASE_VERSION
    RELEASE_VERSION=${RELEASE_VERSION:-$VERSION}

    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    shorebird patch android --release-version "$RELEASE_VERSION"

    echo ""
    echo -e "${GREEN}✅ Patch created successfully!${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Done!${NC}"
