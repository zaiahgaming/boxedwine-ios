#!/usr/bin/env bash
set -e

echo "======================================================"
echo "      Boxedwine iOS Game Launcher Setup Script        "
echo "======================================================"

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOXEDWINE_DIR="$PROJECT_DIR/Boxedwine"

if [ ! -d "$BOXEDWINE_DIR/.git" ]; then
    echo "[+] Cloning Boxedwine repository from GitHub..."
    git clone https://github.com/danoon2/Boxedwine.git "$BOXEDWINE_DIR"
else
    echo "[✓] Boxedwine repository already present."
fi

echo "[+] Creating build directories..."
mkdir -p "$PROJECT_DIR/build-ios"
mkdir -p "$PROJECT_DIR/iOS"

echo "[✓] Setup completed successfully!"
echo "To generate the iOS Xcode project, run:"
echo "  cd build-ios && cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 .."
