#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "    Boxedwine iOS (.ipa) Xcode Project Generator Script   "
echo "=========================================================="

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[1] Creating build directory..."
mkdir -p "$PROJECT_DIR/build-ios"
cd "$PROJECT_DIR/build-ios"

echo "[2] Running CMake to generate native Xcode iOS Project..."
cmake -G Xcode \
      -DCMAKE_SYSTEM_NAME=iOS \
      -DCMAKE_OSX_ARCHITECTURES=arm64 \
      -DCMAKE_OSX_SYSROOT=iphoneos \
      ..

echo ""
echo "[✓] Xcode Project successfully generated at: $PROJECT_DIR/build-ios/BoxedwineGame.xcodeproj"
echo ""
echo "To build the signed .ipa file on your Mac or CI:"
echo "  1. Open build-ios/BoxedwineGame.xcodeproj in Xcode"
echo "  2. Select your Apple Developer Signing Team"
echo "  3. Go to Product -> Archive"
echo "  4. Click 'Distribute App' -> Export as Development / Ad-Hoc / Sideloadable .ipa"
