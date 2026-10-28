# Volume via SUPER+ALT+scroll (keeps SUPER+scroll = workspaces)
# Drop-in snippet for Omarchy/Hyprland's Lua bindings (bindings.lua).
# Adjust the path if volume-scroll lives somewhere other than ~/.local/bin.
hl.unbind("SUPER + ALT + mouse_up")
hl.unbind("SUPER + ALT + mouse_down")
o.bind("SUPER + ALT + mouse_up", "Volume up", os.getenv("HOME") .. "/.local/bin/volume-scroll +")
o.bind("SUPER + ALT + mouse_down", "Volume down", os.getenv("HOME") .. "/.local/bin/volume-scroll -")
