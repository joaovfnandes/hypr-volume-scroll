#!/usr/bin/env bash
# Installer: copies volume-scroll into ~/.local/bin and prints the Hyprland bindings.
# It does not edit any existing Hyprland config.
set -euo pipefail

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
dest_dir="${XDG_BIN_HOME:-$HOME/.local/bin}"
dest="$dest_dir/volume-scroll"

mkdir -p "$dest_dir"
install -m 755 "$here/volume-scroll" "$dest"
echo "installed: $dest"

missing=()
for dep in pactl; do
  command -v "$dep" >/dev/null 2>&1 || missing+=("$dep")
done
if ((${#missing[@]})); then
  echo "warning: missing dependency: ${missing[*]}" >&2
fi
command -v omarchy-osd >/dev/null 2>&1 ||
  echo "note: omarchy-osd not found; volume will change without the on-screen display." >&2

echo
echo "Add this to ~/.config/hypr/bindings.lua (Lua config):"
cat <<EOF

-- Volume via SUPER+ALT+scroll (keeps SUPER+scroll = workspaces)
hl.unbind("SUPER + ALT + mouse_up")
hl.unbind("SUPER + ALT + mouse_down")
o.bind("SUPER + ALT + mouse_up", "Volume up", "$dest +")
o.bind("SUPER + ALT + mouse_down", "Volume down", "$dest -")
EOF

echo
echo "Or, for a classic .conf config:"
cat <<EOF

bind = SUPER ALT, mouse_up, exec, $dest +
bind = SUPER ALT, mouse_down, exec, $dest -
EOF

echo
echo "Then reload Hyprland (hyprctl reload) and scroll."
