#!/usr/bin/env bash

RECORD_SCRIPT="$HOME/.config/hypr/scripts/switch_last_workspace.sh"

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    if [[ $line == "workspace>>"* ]]; then
        $RECORD_SCRIPT
    fi
done