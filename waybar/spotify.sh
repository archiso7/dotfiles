#!/bin/bash

# Get the player status (Playing/Paused)
status=$(playerctl status 2>/dev/null)

# Get the metadata (title - artist)
metadata=$(playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null)

# Output the player status
if [ "$status" = "Playing" ]; then
    echo ""
elif [ "$status" = "Paused" ]; then
    echo -e "\u25BA"
else
    echo ""
fi

# Output the metadata for the tooltip
echo "$metadata"

