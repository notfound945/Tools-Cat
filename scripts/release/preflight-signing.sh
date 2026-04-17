#!/bin/bash
set -euo pipefail

require_command() {
    local name="$1"
    if ! command -v "$name" >/dev/null 2>&1; then
        echo "[ERROR] Required command not found: $name" >&2
        exit 1
    fi
}

require_command "xcodebuild"
require_command "hdiutil"
require_command "ditto"

echo "[OK] Local-share release preflight passed"
