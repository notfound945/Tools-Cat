#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

rg -q 'notarize-dmg\.sh' release.sh
rg -q 'stapler staple "\$DMG_PATH"' release.sh
rg -q 'assess-notarized-dmg\.sh' release.sh

rg -q 'xcrun notarytool submit' scripts/release/notarize-dmg.sh
rg -q -- '--wait' scripts/release/notarize-dmg.sh
rg -q 'Tools-Cat-notary-submit\.plist' scripts/release/notarize-dmg.sh
rg -q 'Tools-Cat-notary-log\.json' scripts/release/notarize-dmg.sh
rg -q 'plutil -extract id' scripts/release/notarize-dmg.sh
rg -q 'plutil -extract status' scripts/release/notarize-dmg.sh
rg -q 'xcrun notarytool log' scripts/release/notarize-dmg.sh

rg -q 'stapler validate' scripts/release/assess-notarized-dmg.sh
rg -q 'spctl --assess --type open -v' scripts/release/assess-notarized-dmg.sh

! rg -q 'exportNotarizedApp' release.sh
! rg -q 'APPLE_ID' scripts/release/notarize-dmg.sh

echo "[OK] Release notarization checks passed"
