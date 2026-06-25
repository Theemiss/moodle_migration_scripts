#!/bin/bash
set -euo pipefail

THEME_TAR_FILE="${THEME_TAR_FILE:-./Themes/theme.tar.gz}"
THEMES_DIR="${THEMES_DIR:-./moodle_installation/theme}"

if [ ! -f "$THEME_TAR_FILE" ]; then
  echo "Theme archive not found: $THEME_TAR_FILE"
  exit 1
fi

mkdir -p "$THEMES_DIR"
tar -xzf "$THEME_TAR_FILE" -C "$THEMES_DIR"

THEME_DIR=$(tar -tf "$THEME_TAR_FILE" | head -n 1 | sed -e 's@/.*@@')
TARGET_NAME="${THEME_NAME:-$THEME_DIR}"

if [ -d "$THEMES_DIR/$THEME_DIR" ]; then
  mv "$THEMES_DIR/$THEME_DIR" "$THEMES_DIR/$TARGET_NAME"
fi

echo "[OK] Theme installed to $THEMES_DIR/$TARGET_NAME"
