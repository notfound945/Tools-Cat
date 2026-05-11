#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

rg -q 'xcodebuild build' release.sh
rg -q 'derivedDataPath "\$DERIVED_DATA_PATH"' release.sh
rg -q 'CODE_SIGNING_ALLOWED=NO' release.sh
rg -q 'CODE_SIGNING_REQUIRED=NO' release.sh
rg -q 'ad-hoc-sign-friend-share-app\.sh' release.sh
rg -q 'build_dmg\.sh' release.sh
rg -q 'Tools-Cat\.dmg' release.sh
rg -q 'build_dmg\.sh" "\$BUILD_APP_PATH" "Tools-Cat\.dmg" "Tools Cat"' release.sh
! rg -q 'clean build' release.sh
! rg -q 'xcodebuild -exportArchive' release.sh
! rg -q 'notarize-dmg\.sh' release.sh
! rg -q 'stapler staple' release.sh

rg -q 'xcodebuild' scripts/release/preflight-signing.sh
rg -q 'hdiutil' scripts/release/preflight-signing.sh
rg -q 'ditto' scripts/release/preflight-signing.sh
rg -q 'codesign' scripts/release/preflight-signing.sh
! rg -q 'RELEASE_NOTARY_PROFILE' scripts/release/preflight-signing.sh
! rg -q 'Developer ID Application' scripts/release/preflight-signing.sh

rg -q 'hdiutil create' build_dmg.sh
rg -Fq 'DMG_NAME=${2:-Tools-Cat.dmg}' build_dmg.sh
rg -q 'codesign --force --deep --sign -' scripts/release/ad-hoc-sign-friend-share-app.sh
rg -q 'PlistBuddy -c' scripts/release/ad-hoc-sign-friend-share-app.sh
rg -q 'CODE_SIGN_STYLE = Automatic;' 'Tools Cat.xcodeproj/project.pbxproj'

echo "[OK] Friend-share release readiness checks passed"
