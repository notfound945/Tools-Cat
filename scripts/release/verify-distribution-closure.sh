#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT="Tools Cat.xcodeproj"
SCHEME="Tools Cat"
DESTINATION="platform=macOS"

cd "$ROOT_DIR"

echo "Running the Phase 18 distribution verification closure."
echo "This checks the friend-share DMG contract, inspects the shipped artifact, and reruns focused WOL/keep-awake regressions."

bash "$ROOT_DIR/scripts/release/verify-release-readiness.sh"
bash "$ROOT_DIR/scripts/release/verify-release-docs.sh"
bash "$ROOT_DIR/scripts/release/verify-friend-share-artifact.sh"

run_slice() {
  local label="$1"
  shift

  echo
  echo "==> $label"

  xcodebuild test \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -parallel-testing-enabled NO \
    "$@"
}

run_slice "Focused WOL and keep-awake model regressions" \
  -only-testing:'Tools CatTests/WOLSessionModelTests' \
  -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' \
  -only-testing:'Tools CatTests/KeepAwakeMenuStateTests'

echo
echo "==> Menu-bar verification slice"
bash "$ROOT_DIR/scripts/run_menu_bar_verification_slice.sh"

echo
echo "[OK] Distribution verification closure passed"
echo "[NOTE] Fresh-machine and real friend-side Gatekeeper validation remain manual."
