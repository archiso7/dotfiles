#!/bin/bash
# Delegate to the single idle/lock script. Do not start a second swayidle here — that stacked two
# swaylocks (unlock removed one; the next click hit the other).
#
# hyprland.conf runs ~/.config/wm-common/idle.sh via exec-once; start.sh also runs this script.
# idle.sh begins with pkill swayidle, so calling it twice at login is safe (only one daemon remains).
~/.config/wm-common/idle.sh
