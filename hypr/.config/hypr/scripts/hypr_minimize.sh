#!/bin/bash

STACK_FILE="/tmp/hypr_stack"
SPECIAL_NAME="minimize"
SPECIAL_WS="special:$SPECIAL_NAME"

FOCUS_ON_RESTORE=true
CLOSE_SPECIAL_ON_POP=true
EXCLUDE_FILTER="(waybar|dunst|mako)"

touch "$STACK_FILE"

window_exists() {
    hyprctl clients -j | jq -e ".[] | select(.address == \"$1\")" > /dev/null
}

get_target_workspace() {
    active_ws_name=$(hyprctl activeworkspace -j | jq -r '.name')
    if [[ "$active_ws_name" == "$SPECIAL_WS" ]]; then
        hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id'
    else
        hyprctl activeworkspace -j | jq -r '.id'
    fi
}

case "$1" in
    "push")
        if [[ "$2" == "--all" ]]; then
            active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
            addrs=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $active_ws) | select(.class | test(\"$EXCLUDE_FILTER\") | not) | .address")
            
            if [[ -n "$addrs" && "$addrs" != "null" ]]; then
                while read -r addr; do
                    if [[ -n "$addr" && "$addr" != "null" ]]; then
                        echo "$addr" >> "$STACK_FILE"
                        hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$addr"
                    fi
                done <<< "$addrs"
            fi
        else
            active_win=$(hyprctl activewindow -j)
            addr=$(echo "$active_win" | jq -r '.address')
            class=$(echo "$active_win" | jq -r '.class')
            
            if [[ "$addr" != "null" && -n "$addr" ]] && ! [[ "$class" =~ $EXCLUDE_FILTER ]]; then
                echo "$addr" >> "$STACK_FILE"
                hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$addr"
            fi
        fi
        ;;

    "pop")
        target_ws=$(get_target_workspace)

        if [[ ! -s "$STACK_FILE" ]]; then
            tray_addrs=$(hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"$SPECIAL_WS\") | .address")
            
            if [[ -z "$tray_addrs" || "$tray_addrs" == "null" ]]; then
                hyprctl dispatch togglespecialworkspace "$SPECIAL_NAME"
                exit 0
            fi
            
            echo "$tray_addrs" > "$STACK_FILE"
        fi

        if [[ "$2" == "--all" ]]; then
            while read -r addr; do
                if [[ -n "$addr" ]] && window_exists "$addr"; then
                    hyprctl dispatch movetoworkspacesilent "$target_ws,address:$addr"
                fi
            done < "$STACK_FILE"
            > "$STACK_FILE"
            
            curr_ws=$(hyprctl activeworkspace -j | jq -r '.name')
            [[ "$CLOSE_SPECIAL_ON_POP" == true && "$curr_ws" == "$SPECIAL_WS" ]] && hyprctl dispatch togglespecialworkspace "$SPECIAL_NAME"
        else
            while [ -s "$STACK_FILE" ]; do
                addr=$(tail -n 1 "$STACK_FILE")
                sed -i '$d' "$STACK_FILE"
                
                if [[ -n "$addr" ]] && window_exists "$addr"; then
                    hyprctl dispatch movetoworkspacesilent "$target_ws,address:$addr"
                    [[ "$FOCUS_ON_RESTORE" == true ]] && hyprctl dispatch focuswindow "address:$addr"
                    
                    curr_ws=$(hyprctl activeworkspace -j | jq -r '.name')
                    [[ "$CLOSE_SPECIAL_ON_POP" == true && "$curr_ws" == "$SPECIAL_WS" ]] && hyprctl dispatch togglespecialworkspace "$SPECIAL_NAME"
                    break
                fi
            done
        fi
        ;;

    "toggle")
        hyprctl dispatch togglespecialworkspace "$SPECIAL_NAME"
        ;;
esac