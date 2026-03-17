#!/bin/bash

CLASS="dropdown_term"

if hyprctl clients -j | jq -e ".[] | select(.class == \"$CLASS\")" > /dev/null; then
    ACTIVE_CLASS=$(hyprctl activewindow -j | jq -r '.class')
    
    if [ "$ACTIVE_CLASS" == "$CLASS" ]; then
        hyprctl dispatch killactive ""
    else
        hyprctl dispatch focuswindow class:"$CLASS"
    fi
else
    hyprctl dispatch exec "$TERMINAL --class $CLASS"
fi