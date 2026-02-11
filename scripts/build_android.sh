#!/usr/bin/env bash
set -euo pipefail

# One-command Android APK export for the Godot prototype.
# Usage:
#   ./scripts/build_android.sh
#   ./scripts/build_android.sh --release
#   ./scripts/build_android.sh --output build/MyGame.apk

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/godot_app"
DEFAULT_OUTPUT_DEBUG="$ROOT_DIR/build/EpochOfEmbersPrototype-debug.apk"
DEFAULT_OUTPUT_RELEASE="$ROOT_DIR/build/EpochOfEmbersPrototype-release.apk"

BUILD_TYPE="debug"
OUTPUT_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --release)
      BUILD_TYPE="release"
      shift
      ;;
    --debug)
      BUILD_TYPE="debug"
      shift
      ;;
    --output)
      OUTPUT_PATH="${2:-}"
      if [[ -z "$OUTPUT_PATH" ]]; then
        echo "ERROR: --output requires a file path." >&2
        exit 1
      fi
      shift 2
      ;;
    -h|--help)
      cat <<USAGE
Usage: ./scripts/build_android.sh [--debug|--release] [--output <apk-path>]

Options:
  --debug        Export debug APK (default)
  --release      Export release APK (requires release signing configured in export_presets.cfg)
  --output PATH  Output APK path
USAGE
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$OUTPUT_PATH" ]]; then
  if [[ "$BUILD_TYPE" == "release" ]]; then
    OUTPUT_PATH="$DEFAULT_OUTPUT_RELEASE"
  else
    OUTPUT_PATH="$DEFAULT_OUTPUT_DEBUG"
  fi
fi

if command -v godot4 >/dev/null 2>&1; then
  GODOT_BIN="godot4"
elif command -v godot >/dev/null 2>&1; then
  GODOT_BIN="godot"
else
  echo "ERROR: Godot CLI not found. Install Godot 4 and ensure 'godot4' (or 'godot') is in PATH." >&2
  exit 1
fi

if [[ ! -f "$PROJECT_DIR/project.godot" ]]; then
  echo "ERROR: Missing Godot project at $PROJECT_DIR/project.godot" >&2
  exit 1
fi

if [[ ! -f "$PROJECT_DIR/export_presets.cfg" ]]; then
  cat <<EOFMSG >&2
ERROR: Missing $PROJECT_DIR/export_presets.cfg
Create it once from Godot editor:
  Project -> Export... -> Add Android preset named "Android"
Then rerun this script.
EOFMSG
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

EXPORT_FLAG="--export-debug"
if [[ "$BUILD_TYPE" == "release" ]]; then
  EXPORT_FLAG="--export-release"
fi

echo "Using Godot binary: $GODOT_BIN"
echo "Project: $PROJECT_DIR"
echo "Build type: $BUILD_TYPE"
echo "Output: $OUTPUT_PATH"

set -x
"$GODOT_BIN" --headless --path "$PROJECT_DIR" "$EXPORT_FLAG" "Android" "$OUTPUT_PATH"
set +x

echo "APK exported: $OUTPUT_PATH"

if command -v adb >/dev/null 2>&1; then
  cat <<EOFMSG
Tip: install directly to a connected device with:
  adb install -r "$OUTPUT_PATH"
EOFMSG
else
  echo "Tip: adb not found in PATH. Install Android platform-tools to use one-command install."
fi
