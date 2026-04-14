#!/bin/bash
set -euo pipefail

# Build Release with xcodebuild, then package DMG using build_dmg.sh
# Uses wildcard to locate the only .app under build/Build/Products/Release
#
# Env overrides (optional):
#   PROJECT  - default: "Tools Cat.xcodeproj"
#   SCHEME   - default: "Tools Cat"
#   CONFIG   - default: "Release"
#   DERIVED  - default: "build"
#   DMG_NAME - default: "Tools-Cat.dmg"
#   VOL_NAME - default: "Tools Cat"
#   OUT_DIR  - default: "$(pwd)/dist" (used by build_dmg.sh)

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

PROJECT=${PROJECT:-"Tools Cat.xcodeproj"}
SCHEME=${SCHEME:-"Tools Cat"}
CONFIG=${CONFIG:-Release}
DERIVED=${DERIVED:-build}

echo "[BUILD] xcodebuild project=$PROJECT scheme=$SCHEME config=$CONFIG derived=$DERIVED"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIG" -derivedDataPath "$DERIVED" clean build

# Locate app using wildcard; ensure exactly one match
shopt -s nullglob
apps=("$DERIVED/Build/Products/$CONFIG"/*.app)
shopt -u nullglob

if [[ ${#apps[@]} -eq 0 ]]; then
  echo "[ERROR] No .app found in $DERIVED/Build/Products/$CONFIG" >&2
  exit 1
fi
if [[ ${#apps[@]} -gt 1 ]]; then
  echo "[ERROR] Multiple .app bundles found; please disambiguate:" >&2
  printf ' - %s\n' "${apps[@]}" >&2
  exit 1
fi

APP_PATH="${apps[0]}"
echo "[BUILD] Found app: $APP_PATH"

chmod +x "$ROOT_DIR/build_dmg.sh"
"$ROOT_DIR/build_dmg.sh" "$APP_PATH" "${DMG_NAME:-Tools-Cat.dmg}" "${VOL_NAME:-Tools Cat}"

DEFAULT_OUT_DIR="$ROOT_DIR/dist"
FINAL_OUT_DIR="${OUT_DIR:-$DEFAULT_OUT_DIR}"
echo "[DONE] DMG generated in $FINAL_OUT_DIR"
