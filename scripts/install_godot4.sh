#!/usr/bin/env bash
set -euo pipefail

# Installs Godot 4 binary locally (no root required).
# Default install location: ~/.local/bin/godot4
# Usage:
#   ./scripts/install_godot4.sh
#   ./scripts/install_godot4.sh --version 4.2.2 --dest /usr/local/bin/godot4

VERSION="4.2.2"
DEST_PATH="${HOME}/.local/bin/godot4"
TMP_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="${2:-}"
      [[ -n "$VERSION" ]] || { echo "ERROR: --version requires a value" >&2; exit 1; }
      shift 2
      ;;
    --dest)
      DEST_PATH="${2:-}"
      [[ -n "$DEST_PATH" ]] || { echo "ERROR: --dest requires a value" >&2; exit 1; }
      shift 2
      ;;
    -h|--help)
      cat <<USAGE
Usage: ./scripts/install_godot4.sh [--version <4.x.y>] [--dest <path>]

Examples:
  ./scripts/install_godot4.sh
  ./scripts/install_godot4.sh --version 4.3 --dest ~/.local/bin/godot4
USAGE
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo "ERROR: Need curl or wget to download Godot." >&2
  exit 1
fi

ZIP_NAME="Godot_v${VERSION}-stable_linux.x86_64.zip"
URL="https://github.com/godotengine/godot/releases/download/${VERSION}-stable/${ZIP_NAME}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
ARCHIVE_PATH="$TMP_DIR/$ZIP_NAME"

mkdir -p "$(dirname "$DEST_PATH")"

echo "Downloading $URL"
if command -v curl >/dev/null 2>&1; then
  curl -fL "$URL" -o "$ARCHIVE_PATH"
else
  wget -O "$ARCHIVE_PATH" "$URL"
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "ERROR: unzip is required to extract Godot binary." >&2
  exit 1
fi

unzip -q "$ARCHIVE_PATH" -d "$TMP_DIR"
BIN_PATH="$(find "$TMP_DIR" -maxdepth 1 -type f -name 'Godot_v*-stable_linux.x86_64' | head -n 1)"

if [[ -z "$BIN_PATH" || ! -f "$BIN_PATH" ]]; then
  echo "ERROR: Could not find extracted Godot binary in archive." >&2
  exit 1
fi

install -m 0755 "$BIN_PATH" "$DEST_PATH"

echo "Installed Godot to: $DEST_PATH"
echo "Version check:"
"$DEST_PATH" --version || true

echo "If needed, add to PATH:"
echo "  export PATH=\"$(dirname "$DEST_PATH"):\$PATH\""
