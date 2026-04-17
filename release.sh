#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT="Tools Cat.xcodeproj"
SCHEME="Tools Cat"
CONFIGURATION="Release"
DERIVED_DATA_PATH="$ROOT_DIR/build/DerivedData"
BUILD_APP_PATH="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION/Tools Cat.app"
LEGACY_DIST_APP_PATH="$ROOT_DIR/dist/Tools Cat.app"
DMG_PATH="$ROOT_DIR/dist/Tools-Cat.dmg"

cd "$ROOT_DIR"

bash "$ROOT_DIR/scripts/release/preflight-signing.sh"

mkdir -p "$ROOT_DIR/build" "$ROOT_DIR/dist"
rm -rf "$DERIVED_DATA_PATH" "$LEGACY_DIST_APP_PATH" "$DMG_PATH"

echo "[BUILD] Creating local Release app in $DERIVED_DATA_PATH"
xcodebuild build \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "platform=macOS" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO

if [[ ! -d "$BUILD_APP_PATH" ]]; then
    echo "[ERROR] Release app was not produced at $BUILD_APP_PATH" >&2
    exit 1
fi

echo "[BUILD] Packaging DMG to $DMG_PATH"
bash "$ROOT_DIR/build_dmg.sh" "$BUILD_APP_PATH" "Tools-Cat.dmg" "Tools Cat"

echo "[DONE] Release app built at $BUILD_APP_PATH"
echo "[DONE] Friend-share DMG created at $DMG_PATH"
echo "[NOTE] This build is not notarized. Friends may need to right-click open the app or remove quarantine manually."
