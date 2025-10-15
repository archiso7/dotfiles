#!/usr/bin/env bash

# Get active workspace ID
active=$(hyprctl activeworkspace -j | jq -r '.id')

# Get all workspaces that have at least one window
workspaces=($(hyprctl workspaces -j | jq -r '.[] | select(.windows > 0) | .id'))

# Build workspace buttons (HTML-style)
buttons=""
for ws in "${workspaces[@]}"; do
  # Skip the active workspace (we'll display it separately)
  if [[ "$ws" == "$active" ]]; then
    continue
  fi
  buttons+="<button class='ws' onclick='hyprctl dispatch workspace $ws'>$ws</button> "
done

# Escape quotes properly for JSON output
text="<span class='active'>$active</span> | ${buttons::-1}"

# Output **valid JSON** (ensure quotes are escaped)
jq -nc --arg text "$text" '{"text": $text, "class": "workspaces"}'
