#!/bin/bash
set -euo pipefail

DMG_PATH=${1:-}

if [[ -z "$DMG_PATH" ]]; then
    echo "Usage: $0 '/path/to/Tools-Cat.dmg'" >&2
    exit 1
fi

if [[ ! -f "$DMG_PATH" || "$DMG_PATH" != *.dmg ]]; then
    echo "[ERROR] DMG_PATH must be an existing .dmg file" >&2
    exit 1
fi

codesign -d --verbose=4 "$DMG_PATH"
codesign --verify --verbose=4 "$DMG_PATH"
