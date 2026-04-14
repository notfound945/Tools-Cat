#!/bin/bash
set -euo pipefail

# Simple DMG packer using hdiutil (no notarization)
# Usage:
#   ./build_dmg.sh "/absolute/path/to/Tools Cat.app" [DMG_NAME] [VOLUME_NAME]
#
# Example:
#   ./build_dmg.sh "/Users/you/Builds/Tools Cat.app" "Tools-Cat.dmg" "Tools Cat"

APP_PATH=${1:-}
DMG_NAME=${2:-Tools-Cat.dmg}
VOL_NAME=${3:-"Tools Cat"}
OUT_DIR=${OUT_DIR:-"$(pwd)/dist"}

if [[ -z "$APP_PATH" ]]; then
  echo "Usage: $0 '/path/to/App.app' [DMG_NAME] [VOLUME_NAME]" >&2
  exit 1
fi

if [[ ! -d "$APP_PATH" ]] || [[ ! "$APP_PATH" =~ \.app$ ]]; then
  echo "Error: APP_PATH must be an existing .app bundle directory" >&2
  exit 1
fi

STAGE_DIR="$(mktemp -d -t toolscat_dmg.XXXXXX)"
cleanup() { rm -rf "$STAGE_DIR" >/dev/null 2>&1 || true; }
trap cleanup EXIT

APP_NAME="$(basename "$APP_PATH")"

echo "[DMG] Staging to: $STAGE_DIR"
/usr/bin/ditto --noqtn "$APP_PATH" "$STAGE_DIR/$APP_NAME"
ln -s /Applications "$STAGE_DIR/Applications"

mkdir -p "$OUT_DIR"
OUT_PATH="$OUT_DIR/$DMG_NAME"

echo "[DMG] Creating DMG: $OUT_PATH (volume: $VOL_NAME)"
hdiutil create \
  -volname "$VOL_NAME" \
  -srcfolder "$STAGE_DIR" \
  -ov \
  -format UDZO \
  "$OUT_PATH"

echo "[DMG] Done: $OUT_PATH"
echo "Note: DMG 未公证，用户首次安装需在系统隐私与安全中手动允许或使用右键-打开。"

