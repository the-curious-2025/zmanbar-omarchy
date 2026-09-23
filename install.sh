#!/usr/bin/env bash
# Installs the ZmanBar plugin into Omarchy's third-party plugin directory
# and (optionally) adds it to the bar.
#
# Works identically whether run natively on Omarchy or inside the
# try-omarchy-windows VM window's terminal / SSH session — both are the
# same Omarchy shell underneath.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DEST="$HOME/.config/omarchy/plugins/zmanbar"
PLUGIN_FILES=(manifest.json BarWidget.qml Panel.qml Model.js)

for f in "${PLUGIN_FILES[@]}"; do
  if [ ! -f "$SCRIPT_DIR/$f" ]; then
    echo "error: expected to find '$f' next to this script at $SCRIPT_DIR" >&2
    exit 1
  fi
done

mkdir -p "$HOME/.config/omarchy/plugins"
rm -rf "$PLUGIN_DEST"
mkdir -p "$PLUGIN_DEST"
for f in "${PLUGIN_FILES[@]}"; do
  cp "$SCRIPT_DIR/$f" "$PLUGIN_DEST/"
done
echo "Installed to $PLUGIN_DEST"

if command -v omarchy >/dev/null 2>&1; then
  echo "Enabling the widget in the center section of the bar..."
  omarchy plugin enable zmanbar --section center || {
    echo "Could not enable it automatically. Add it yourself with:"
    echo "  omarchy plugin enable zmanbar --section center"
  }
else
  echo "The 'omarchy' command wasn't found on PATH. Once you're inside your Omarchy"
  echo "session, run:"
  echo "  omarchy plugin enable zmanbar --section center"
fi
