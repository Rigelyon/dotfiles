#!/bin/bash

CLASS="dropdown_term"

if hyprctl clients | grep -i -q "class: ${CLASS}"; then
    ACTIVE_CLASS=$(hyprctl activewindow | grep -i "class:" | awk '{print $2}')
    if [ "$ACTIVE_CLASS" = "$CLASS" ]; then
        hyprctl dispatch 'hl.dsp.window.close()'
    else
        hyprctl dispatch "hl.dsp.window.focus({ class = \"${CLASS}\" })"
    fi
else
    kitty --class "${CLASS}" &
fi