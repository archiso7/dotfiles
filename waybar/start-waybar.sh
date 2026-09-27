#!/bin/bash
# Autodetect compositor and start Waybar with the right config

# Kill existing waybar instances
pkill -x waybar 2>/dev/null

sleep 0.2

if pgrep -x niri >/dev/null 2>&1; then
  exec waybar -c "$HOME/.config/waybar/config-niri.jsonc"
elif pgrep -x Hyprland >/dev/null 2>&1 || [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
  exec waybar -c "$HOME/.config/waybar/config-hyprland.jsonc"
elif pgrep -x sway >/dev/null 2>&1 || [ -n "$SWAYSOCK" ]; then
  exec waybar -c "$HOME/.config/waybar/config-sway.jsonc"
else
  # Fallback to default config
  exec waybar
fi

