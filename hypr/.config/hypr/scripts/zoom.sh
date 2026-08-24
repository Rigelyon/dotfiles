#!/bin/bash

current=$(hyprctl -j getoption cursor:zoom_factor 2>/dev/null | jq -r '.float // 1.0' 2>/dev/null)

if [ -z "$current" ] || [ "$current" = "null" ]; then
    current=$(hyprctl getoption cursor:zoom_factor 2>/dev/null | grep -oP 'float:\s*\K[0-9.]+' || echo "1.0")
fi

if [ "$1" = "in" ]; then
    new=$(awk -v c="$current" 'BEGIN { f=c+0.25; if (f > 8) f=8; printf "%.2f", f }')
elif [ "$1" = "out" ]; then
    new=$(awk -v c="$current" 'BEGIN { f=c-0.25; if (f < 1) f=1; printf "%.2f", f }')
fi

if [ -n "$new" ]; then
    hyprctl keyword cursor:zoom_factor "$new"
fi
