#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
DMG_PATH=${1:-}
NOTARY_DIR="$ROOT_DIR/build/notary"
SUBMIT_PLIST="$NOTARY_DIR/Tools-Cat-notary-submit.plist"
LOG_PATH="$NOTARY_DIR/Tools-Cat-notary-log.json"

if [[ -z "$DMG_PATH" ]]; then
    echo "Usage: $0 '/path/to/Tools-Cat.dmg'" >&2
    exit 1
fi

if [[ ! -f "$DMG_PATH" || "$DMG_PATH" != *.dmg ]]; then
    echo "[ERROR] DMG_PATH must be an existing .dmg file" >&2
    exit 1
fi

if [[ -z "${RELEASE_NOTARY_PROFILE:-}" ]]; then
    echo "[ERROR] RELEASE_NOTARY_PROFILE must be set before notarization" >&2
    exit 1
fi

command -v xcrun >/dev/null 2>&1 || {
    echo "[ERROR] xcrun is required for notarization" >&2
    exit 1
}

command -v plutil >/dev/null 2>&1 || {
    echo "[ERROR] plutil is required for notarization metadata parsing" >&2
    exit 1
}

mkdir -p "$NOTARY_DIR"
rm -f "$SUBMIT_PLIST" "$LOG_PATH"

echo "[NOTARY] Submitting $DMG_PATH with profile $RELEASE_NOTARY_PROFILE"
xcrun notarytool submit "$DMG_PATH" \
    --keychain-profile "$RELEASE_NOTARY_PROFILE" \
    --wait \
    --timeout 30m \
    --no-progress \
    -f plist >"$SUBMIT_PLIST"

SUBMISSION_ID="$(plutil -extract id raw -o - "$SUBMIT_PLIST")"
STATUS="$(plutil -extract status raw -o - "$SUBMIT_PLIST")"

echo "[NOTARY] Submission ID: $SUBMISSION_ID"
echo "[NOTARY] Status: $STATUS"

if [[ "$STATUS" != "Accepted" ]]; then
    xcrun notarytool log "$SUBMISSION_ID" "$LOG_PATH" --keychain-profile "$RELEASE_NOTARY_PROFILE"
    echo "[ERROR] Notarization rejected. Submission metadata: $SUBMIT_PLIST" >&2
    echo "[ERROR] Notary log: $LOG_PATH" >&2
    exit 1
fi

echo "[NOTARY] Accepted. Submission metadata: $SUBMIT_PLIST"
