#!/bin/bash

active_workspace=$(hyprctl -j activeworkspace | jq '.id')

if [ -z "$active_workspace" ] || [ "$active_workspace" = "null" ]; then
    exit 1
fi

clients=$(hyprctl -j clients | jq -c "[.[] | select(.workspace.id == $active_workspace)]")

has_tiled=$(echo "$clients" | jq 'map(select(.floating == false)) | length')

if [ "$has_tiled" -gt 0 ]; then
    echo "$clients" | jq -r '.[].address' | while read -r addr; do
        hyprctl dispatch "hl.dsp.window.set_floating({ address = \"$addr\" })"
    done
else
    echo "$clients" | jq -r '.[].address' | while read -r addr; do
        hyprctl dispatch "hl.dsp.window.set_tiled({ address = \"$addr\" })"
    done
fi
