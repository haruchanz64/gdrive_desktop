#!/bin/bash

VERSION="${1:-1.0.0}"
PLATFORM="${2:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
CLEAN="${3:-false}"
APP_NAME="GDrive Desktop"
DIST_DIR="dist"

declare -A OUTPUT_MAP
OUTPUT_MAP["linux"]="build/linux/x64/release/bundle"
OUTPUT_MAP["darwin"]="build/macos/Build/Products/Release"

echo ""
echo "Building $APP_NAME v$VERSION for $PLATFORM"
echo "======================================"

# ── Validate Platform ──────────────────────────────────────────────────────────
if [[ -z "${OUTPUT_MAP[$PLATFORM]}" ]]; then
    echo "Unknown platform '$PLATFORM'. Valid: linux, darwin"
    exit 1
fi

# ── Clean ──────────────────────────────────────────────────────────────────────
if [ "$CLEAN" = "true" ]; then
    echo "Cleaning previous build..."
    flutter clean || exit 1
fi

# ── Dependencies ───────────────────────────────────────────────────────────────
echo "Fetching dependencies..."
flutter pub get || exit 1

# ── Build ──────────────────────────────────────────────────────────────────────
echo "Building for $PLATFORM..."
if [ "$PLATFORM" = "darwin" ]; then
    flutter build macos --release || exit 1
else
    flutter build linux --release || exit 1
fi

# ── Package ────────────────────────────────────────────────────────────────────
echo "Packaging output..."
mkdir -p "$DIST_DIR"

OUTPUT_DIR="${OUTPUT_MAP[$PLATFORM]}"
ZIP_NAME="gdrive_desktop_v${VERSION}_${PLATFORM}.zip"

zip -r "$DIST_DIR/$ZIP_NAME" "$OUTPUT_DIR/"

echo ""
echo "======================================"
echo "Build complete."
echo "Output : $OUTPUT_DIR"
echo "Archive: $DIST_DIR/$ZIP_NAME"
echo ""