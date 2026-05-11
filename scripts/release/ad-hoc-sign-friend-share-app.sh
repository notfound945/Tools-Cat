#!/bin/bash
set -euo pipefail

APP_PATH=${1:-}
ENTITLEMENTS_PATH=${2:-}

if [[ -z "$APP_PATH" || -z "$ENTITLEMENTS_PATH" ]]; then
    echo "Usage: $0 '/path/to/App.app' '/path/to/entitlements.plist'" >&2
    exit 1
fi

if [[ ! -d "$APP_PATH" || "$APP_PATH" != *.app ]]; then
    echo "[ERROR] APP_PATH must be an existing .app bundle directory" >&2
    exit 1
fi

if [[ ! -f "$ENTITLEMENTS_PATH" ]]; then
    echo "[ERROR] ENTITLEMENTS_PATH must be an existing plist file" >&2
    exit 1
fi

INFO_PLIST_PATH="$APP_PATH/Contents/Info.plist"
if [[ ! -f "$INFO_PLIST_PATH" ]]; then
    echo "[ERROR] Missing Info.plist inside app bundle: $INFO_PLIST_PATH" >&2
    exit 1
fi

EXPECTED_BUNDLE_IDENTIFIER=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INFO_PLIST_PATH")

echo "[SIGN] Applying ad-hoc signature to $APP_PATH"
codesign --force --deep --sign - --entitlements "$ENTITLEMENTS_PATH" "$APP_PATH"
codesign --verify --deep --strict "$APP_PATH"

CODESIGN_OUTPUT="$(codesign -dv --verbose=4 "$APP_PATH" 2>&1)"
ACTUAL_BUNDLE_IDENTIFIER="$(printf '%s\n' "$CODESIGN_OUTPUT" | awk -F= '/^Identifier=/{print $2; exit}')"

if [[ "$ACTUAL_BUNDLE_IDENTIFIER" != "$EXPECTED_BUNDLE_IDENTIFIER" ]]; then
    echo "[ERROR] Signed app identifier mismatch: expected $EXPECTED_BUNDLE_IDENTIFIER, got $ACTUAL_BUNDLE_IDENTIFIER" >&2
    exit 1
fi

if ! printf '%s\n' "$CODESIGN_OUTPUT" | grep -q '^Info.plist entries='; then
    echo "[ERROR] Signed app does not have a bound Info.plist; notification permissions may not track the bundle correctly." >&2
    exit 1
fi

echo "[SIGN] Verified ad-hoc signature for bundle id $ACTUAL_BUNDLE_IDENTIFIER"
