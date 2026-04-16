#!/bin/bash
set -euo pipefail

require_env() {
    local name="$1"
    if [[ -z "${!name:-}" ]]; then
        echo "[ERROR] $name is required" >&2
        exit 1
    fi
}

require_command() {
    local name="$1"
    if ! command -v "$name" >/dev/null 2>&1; then
        echo "[ERROR] Required command not found: $name" >&2
        exit 1
    fi
}

require_env "RELEASE_TEAM_ID"
require_env "RELEASE_SIGNING_IDENTITY"
require_env "RELEASE_NOTARY_PROFILE"

require_command "xcodebuild"
require_command "security"
require_command "codesign"
require_command "xcrun"
require_command "plutil"

if [[ "$RELEASE_SIGNING_IDENTITY" != "Developer ID Application:"* ]]; then
    echo "[ERROR] RELEASE_SIGNING_IDENTITY must start with 'Developer ID Application:'" >&2
    exit 1
fi

if ! security find-identity -v -p codesigning | grep -F "$RELEASE_SIGNING_IDENTITY" >/dev/null 2>&1; then
    echo "[ERROR] Developer ID signing identity not found: $RELEASE_SIGNING_IDENTITY" >&2
    exit 1
fi

if ! xcrun notarytool history --keychain-profile "$RELEASE_NOTARY_PROFILE" >/dev/null 2>&1; then
    echo "[ERROR] notarytool profile is missing or invalid: $RELEASE_NOTARY_PROFILE" >&2
    exit 1
fi

echo "[OK] Release signing preflight passed"
