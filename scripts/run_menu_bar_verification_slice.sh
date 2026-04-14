#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="Tools Cat.xcodeproj"
SCHEME="Tools Cat"
DESTINATION="platform=macOS"

cd "$ROOT_DIR"

echo "Running the Phase 7 menu-bar verification slice."
echo "This proves controller seams and direct-launched utility windows; it does not prove live tray clicks."

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

run_slice "Controller seam regressions" \
  -only-testing:'Tools CatTests/StatusBarControllerEntryFlowTests' \
  -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests' \
  -only-testing:'Tools CatTests/StatusBarControllerWakeMenuTests' \
  -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'

run_slice "Direct-launch WOL window smoke" \
  -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithWOLWindowShowsPolishedSections'

run_slice "Direct-launch seeded device library smoke" \
  -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface'

run_slice "Direct-launch empty device library smoke" \
  -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'
