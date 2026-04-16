#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

rg -q 'xcodebuild archive' release.sh
rg -q 'xcodebuild -exportArchive' release.sh
rg -q 'RELEASE_TEAM_ID' release.sh
rg -q 'RELEASE_SIGNING_IDENTITY' release.sh
rg -q 'RELEASE_NOTARY_PROFILE' release.sh
rg -q 'build_dmg\.sh' release.sh
rg -q 'Tools-Cat\.dmg' release.sh
rg -q 'codesign --force --sign "\$RELEASE_SIGNING_IDENTITY" --timestamp "\$DMG_PATH"' release.sh
rg -q 'inspect-dmg-signature\.sh' release.sh
! rg -q 'clean build' release.sh
! rg -q 'Build/Products/Release' release.sh

rg -q 'security find-identity -v -p codesigning' scripts/release/preflight-signing.sh
rg -q 'xcrun notarytool history --keychain-profile' scripts/release/preflight-signing.sh

rg -q 'developer-id' scripts/release/export-options-developer-id.plist.template
rg -q 'manual' scripts/release/export-options-developer-id.plist.template
rg -q 'Developer ID Application' scripts/release/export-options-developer-id.plist.template

rg -q 'codesign -d --entitlements :- --verbose=4' scripts/release/inspect-signature.sh
rg -q 'codesign -v --verbose=4' scripts/release/inspect-signature.sh
rg -q 'hdiutil create' build_dmg.sh
! rg -q '未公证' build_dmg.sh
rg -q 'codesign -d --verbose=4' scripts/release/inspect-dmg-signature.sh
rg -q 'codesign --verify --verbose=4' scripts/release/inspect-dmg-signature.sh

rg -q 'ENABLE_HARDENED_RUNTIME = YES;' 'Tools Cat.xcodeproj/project.pbxproj'
rg -q 'DEVELOPMENT_TEAM = Y2YJ48R9GL;' 'Tools Cat.xcodeproj/project.pbxproj'
rg -q 'CODE_SIGN_STYLE = Automatic;' 'Tools Cat.xcodeproj/project.pbxproj'

echo "[OK] Release signing readiness checks passed"
