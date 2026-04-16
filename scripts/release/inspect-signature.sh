#!/bin/bash
set -euo pipefail

appPath=${1:-}

if [[ -z "$appPath" ]]; then
    echo "Usage: $0 '/path/to/App.app'" >&2
    exit 1
fi

if [[ ! -d "$appPath" || "$appPath" != *.app ]]; then
    echo "[ERROR] APP_PATH must be an existing .app bundle directory" >&2
    exit 1
fi

codesign -d --entitlements :- --verbose=4 "$appPath"
codesign -v --verbose=4 "$appPath"
