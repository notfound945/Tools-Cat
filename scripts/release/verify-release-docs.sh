#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

rg -q 'sh \./release\.sh' README.md
rg -q 'RELEASE_TEAM_ID' README.md
rg -q 'RELEASE_SIGNING_IDENTITY' README.md
rg -q 'RELEASE_NOTARY_PROFILE' README.md
rg -q 'docs/release/signing-readiness\.md' README.md
rg -q 'dist/Tools-Cat\.dmg' README.md
! rg -q '构建 Release（二选一）' README.md
! rg -q 'Phase 17\+' README.md
! rg -q '隐私与安全' README.md
! rg -q '右键-打开' README.md
! rg -q '未公证' README.md

rg -q 'RELEASE_TEAM_ID=Y2YJ48R9GL' docs/release/signing-readiness.md
rg -q 'RELEASE_NOTARY_PROFILE=TOOLS_CAT_NOTARY' docs/release/signing-readiness.md
rg -q 'xcrun notarytool store-credentials TOOLS_CAT_NOTARY' docs/release/signing-readiness.md
rg -q 'Developer ID Application: <Common Name> \(Y2YJ48R9GL\)' docs/release/signing-readiness.md
rg -q 'dist/Tools-Cat\.dmg' docs/release/signing-readiness.md
rg -q 'Tools-Cat-notary-submit\.plist' docs/release/signing-readiness.md
rg -q 'Tools-Cat-notary-log\.json' docs/release/signing-readiness.md
rg -q 'stapler validate' docs/release/signing-readiness.md
rg -q 'spctl --assess --type open -v' docs/release/signing-readiness.md
rg -q 'Phase 18' docs/release/signing-readiness.md
! rg -q 'Phase 17\+' docs/release/signing-readiness.md
! rg -q '隐私与安全' docs/release/signing-readiness.md
! rg -q '右键-打开' docs/release/signing-readiness.md
! rg -q '未公证' docs/release/signing-readiness.md

echo "[OK] Release documentation matches the notarized DMG contract"
