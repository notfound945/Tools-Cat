#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

rg -q 'sh \./release\.sh' README.md
rg -q 'docs/release/signing-readiness\.md' README.md
rg -q 'dist/Tools-Cat\.dmg' README.md
rg -q '右键打开' README.md
rg -q 'xattr -dr com\.apple\.quarantine' README.md
! rg -q 'RELEASE_NOTARY_PROFILE' README.md
! rg -q 'Developer ID Application' README.md

rg -q 'Apple Developer Program' docs/release/signing-readiness.md
rg -q 'CODE_SIGNING_ALLOWED=NO' docs/release/signing-readiness.md
rg -q 'dist/Tools-Cat\.dmg' docs/release/signing-readiness.md
rg -q '右键打开' docs/release/signing-readiness.md
rg -q 'xattr -dr com\.apple\.quarantine' docs/release/signing-readiness.md
! rg -q 'TOOLS_CAT_NOTARY' docs/release/signing-readiness.md
! rg -q 'notarytool' docs/release/signing-readiness.md

echo "[OK] Release documentation matches the friend-share DMG contract"
