#!/bin/bash
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-./moodle_installation}"
PLUGIN_FILE="${PLUGIN_FILE:-./plugins.json}"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required. Install with: apt install jq"
  exit 1
fi

if [ ! -f "$PLUGIN_FILE" ]; then
  echo "Plugin manifest not found: $PLUGIN_FILE"
  exit 1
fi

mkdir -p "$INSTALL_DIR/mod" "$INSTALL_DIR/local"
cd "$INSTALL_DIR/.."

echo "[*] Installing Moodle plugins from $PLUGIN_FILE"
jq -c '.[]' "$PLUGIN_FILE" | while read -r plugin; do
  name=$(echo "$plugin" | jq -r '.name')
  link=$(echo "$plugin" | jq -r '.link')
  type=$(echo "$plugin" | jq -r '.type')

  case "$type" in
    zip)
      curl -fsSL "$link" -o "$name.zip"
      unzip -q "$name.zip" -d "$name"
      rm "$name.zip"
      mv "$name" "$INSTALL_DIR/$(basename "$link" | cut -d. -f1)"
      ;;
    tar.gz)
      curl -fsSL "$link" -o "$name.tar.gz"
      tar -xzf "$name.tar.gz"
      rm "$name.tar.gz"
      mv "$name" "$INSTALL_DIR/$name"
      ;;
    git)
      git clone --depth 1 "$link" "$name"
      mv "$name" "$INSTALL_DIR/$name"
      ;;
    *)
      echo "[!] Unknown plugin type for $name: $type"
      continue
      ;;
  esac

  echo "[OK] Installed $name"
done

echo "[OK] Plugin installation completed"
