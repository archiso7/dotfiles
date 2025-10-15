#!/bin/bash
export XDG_CURRENT_DESKTOP=Unity
# swaybg -m fill -i ~/.config/hypr/catppuccin.png &
hyprpaper &
lxpolkit &
waybar &
~/.config/hypr/scripts/sleep.sh &
# eww open bar &
prime-offload &
~/.config/wpg/wp_init.sh &
# start way-displays
~/.config/hypr/start-way-displays.sh &
