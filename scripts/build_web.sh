#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/godot_app"
OUTPUT_PATH="${1:-$ROOT_DIR/build/web/index.html}"

if command -v godot4 >/dev/null 2>&1; then
  GODOT_BIN="godot4"
elif command -v godot >/dev/null 2>&1; then
  GODOT_BIN="godot"
else
  echo "ERROR: Godot CLI not found." >&2
  exit 1
fi

if [[ ! -f "$PROJECT_DIR/export_presets.cfg" ]]; then
  echo "ERROR: $PROJECT_DIR/export_presets.cfg missing." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "Web" "$OUTPUT_PATH"

echo "Web build exported to $OUTPUT_PATH"
