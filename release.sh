#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT="Tools Cat.xcodeproj"
SCHEME="Tools Cat"
CONFIGURATION="Release"
ARCHIVE_PATH="$ROOT_DIR/build/archive/Tools Cat.xcarchive"
EXPORT_OPTIONS_TEMPLATE="$ROOT_DIR/scripts/release/export-options-developer-id.plist.template"
EXPORT_OPTIONS_PATH="$ROOT_DIR/build/export-options/developer-id.plist"
EXPORT_PATH="$ROOT_DIR/dist/export"
SIGNED_APP_PATH="$EXPORT_PATH/Tools Cat.app"
DMG_PATH="$ROOT_DIR/dist/Tools-Cat.dmg"

cd "$ROOT_DIR"

bash "$ROOT_DIR/scripts/release/preflight-signing.sh"

mkdir -p "$ROOT_DIR/build/archive" "$ROOT_DIR/build/export-options" "$ROOT_DIR/dist"
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH" "$DMG_PATH"

sed "s/__TEAM_ID__/$RELEASE_TEAM_ID/g" "$EXPORT_OPTIONS_TEMPLATE" >"$EXPORT_OPTIONS_PATH"
plutil -lint "$EXPORT_OPTIONS_PATH" >/dev/null

echo "[BUILD] Release team: $RELEASE_TEAM_ID"
echo "[BUILD] Release identity: $RELEASE_SIGNING_IDENTITY"
echo "[BUILD] Notary profile: $RELEASE_NOTARY_PROFILE"
echo "[BUILD] Archiving signed app to $ARCHIVE_PATH"
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=macOS" \
    -archivePath "$ARCHIVE_PATH" \
    DEVELOPMENT_TEAM="$RELEASE_TEAM_ID" \
    CODE_SIGN_IDENTITY="$RELEASE_SIGNING_IDENTITY"

echo "[BUILD] Exporting signed app to $EXPORT_PATH"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PATH"

bash "$ROOT_DIR/scripts/release/inspect-signature.sh" "$SIGNED_APP_PATH"

echo "[BUILD] Packaging signed DMG to $DMG_PATH"
bash "$ROOT_DIR/build_dmg.sh" "$SIGNED_APP_PATH" "Tools-Cat.dmg" "Tools Cat"

echo "[BUILD] Signing DMG at $DMG_PATH"
codesign --force --sign "$RELEASE_SIGNING_IDENTITY" --timestamp "$DMG_PATH"

bash "$ROOT_DIR/scripts/release/inspect-dmg-signature.sh" "$DMG_PATH"

bash "$ROOT_DIR/scripts/release/notarize-dmg.sh" "$DMG_PATH"
xcrun stapler staple "$DMG_PATH"
bash "$ROOT_DIR/scripts/release/assess-notarized-dmg.sh" "$DMG_PATH"

echo "[DONE] Signed app exported to $SIGNED_APP_PATH"
echo "[DONE] Stapled DMG ready at $DMG_PATH"
