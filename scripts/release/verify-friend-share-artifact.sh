#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD_APP_PATH="$ROOT_DIR/build/DerivedData/Build/Products/Release/Tools Cat.app"
DMG_PATH="$ROOT_DIR/dist/Tools-Cat.dmg"
MOUNT_DIR="$(mktemp -d -t toolscat_verify_mount.XXXXXX)"
DEVICE=""

cleanup() {
    if [[ -n "$DEVICE" ]]; then
        hdiutil detach "$DEVICE" -quiet >/dev/null 2>&1 || true
    fi
    rm -rf "$MOUNT_DIR"
}
trap cleanup EXIT

require_path() {
    local path="$1"
    local kind="$2"

    if [[ ! -e "$path" ]]; then
        echo "[ERROR] Missing $kind: $path" >&2
        echo "[ERROR] Run 'sh ./release.sh' before Phase 18 artifact verification." >&2
        exit 1
    fi
}

require_path "$BUILD_APP_PATH" "Release app bundle"
require_path "$DMG_PATH" "friend-share DMG"

echo "[CHECK] Attaching friend-share DMG"
ATTACH_OUTPUT="$(hdiutil attach "$DMG_PATH" -nobrowse -readonly -mountpoint "$MOUNT_DIR")"
DEVICE="$(printf '%s\n' "$ATTACH_OUTPUT" | awk '/^\/dev\// { print $1; exit }')"

if [[ -z "$DEVICE" ]]; then
    echo "[ERROR] Could not determine attached device for $DMG_PATH" >&2
    exit 1
fi

if [[ ! -d "$MOUNT_DIR/Tools Cat.app" ]]; then
    echo "[ERROR] Mounted DMG does not contain Tools Cat.app" >&2
    exit 1
fi

if [[ ! -L "$MOUNT_DIR/Applications" ]]; then
    echo "[ERROR] Mounted DMG is missing the Applications install shortcut" >&2
    exit 1
fi

if [[ "$(readlink "$MOUNT_DIR/Applications")" != "/Applications" ]]; then
    echo "[ERROR] Applications shortcut does not target /Applications" >&2
    exit 1
fi

echo "[OK] Friend-share artifact layout verified"
echo "[NOTE] Manual-open boundary remains: drag into /Applications, then use \"右键打开\". If Gatekeeper still blocks launch, remove quarantine with xattr."
