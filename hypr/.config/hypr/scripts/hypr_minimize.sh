#!/bin/bash

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STACK_FILE="$RUNTIME_DIR/hypr_stack_$USER"
LOCK_FILE="$STACK_FILE.lock"
SPECIAL_NAME="minimize"
SPECIAL_WS="special:$SPECIAL_NAME"

FOCUS_ON_RESTORE=false
EXCLUDE_FILTER="(waybar|dunst|mako)"

if ! command -v jq &> /dev/null; then
    notify-send "Hypr Minimize" "Error: jq is not installed"
    exit 1
fi

touch "$STACK_FILE"

window_exists() {
    hyprctl clients -j | jq -e ".[] | select(.address == \"$1\")" > /dev/null
}

# Helper: dispatch using Lua dispatcher syntax (required for Hyprland 0.55+ with Lua config)
dispatch_move_to_ws() {
    local ws="$1"
    local addr="$2"
    if [[ -n "$addr" ]]; then
        hyprctl dispatch "hl.dsp.window.move({ workspace = \"$ws\", address = \"$addr\", follow = false})"
    else
        hyprctl dispatch "hl.dsp.window.move({ workspace = \"$ws\", follow = false })"
    fi
}

(
    flock -x 200 || exit 1

    case "$1" in
        "push")
            active_win=$(hyprctl activewindow -j)
            addr=$(echo "$active_win" | jq -r '.address')
            class=$(echo "$active_win" | jq -r '.class')
            win_ws=$(echo "$active_win" | jq -r '.workspace.name')

            if [[ "$win_ws" == "$SPECIAL_WS" || "$addr" == "null" || -z "$addr" ]]; then exit 0; fi
            if [[ "$class" =~ $EXCLUDE_FILTER ]]; then exit 0; fi

            if [[ "$2" == "--all" ]]; then
                active_ws_id=$(hyprctl activeworkspace -j | jq -r '.id')
                addrs=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $active_ws_id) | select(.class | test(\"$EXCLUDE_FILTER\") | not) | .address")

                if [[ -n "$addrs" && "$addrs" != "null" ]]; then
                    while read -r a; do
                        echo "$a" >> "$STACK_FILE"
                        dispatch_move_to_ws "$SPECIAL_WS" "$a"
                    done <<< "$addrs"
                fi
            else
                echo "$addr" >> "$STACK_FILE"
                out=$(dispatch_move_to_ws "$SPECIAL_WS" 2>&1)
                echo "$out" > "$HOME/.config/hypr/scripts/minimize_error.log"
                if [[ -n "$out" && "$out" != "ok" ]]; then
                    notify-send "Hypr Minimize" "Error logged"
                fi
            fi
            ;;

        "pop")
            active_win_info=$(hyprctl activewindow -j)
            focused_addr=$(echo "$active_win_info" | jq -r '.address')
            win_ws_name=$(echo "$active_win_info" | jq -r '.workspace.name')
            target_ws=$(hyprctl activeworkspace -j | jq -r '.id')

            if [[ ! -s "$STACK_FILE" ]]; then
                tray_addrs=$(hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"$SPECIAL_WS\") | .address")
                if [[ -z "$tray_addrs" || "$tray_addrs" == "null" ]]; then
                    notify-send -a "Minimize" -u low "No windows in stack"
                    exit 0
                fi
                echo "$tray_addrs" > "$STACK_FILE"
            fi

            if [[ "$2" == "--all" ]]; then
                while read -r addr; do
                    if [[ -n "$addr" ]] && window_exists "$addr"; then
                        dispatch_move_to_ws "$target_ws" "$addr"
                    fi
                done < "$STACK_FILE"
                > "$STACK_FILE"
            else
                if [[ "$win_ws_name" == "$SPECIAL_WS" && "$focused_addr" != "null" ]]; then
                    sed -i "/$focused_addr/d" "$STACK_FILE"
                    dispatch_move_to_ws "$target_ws" "$focused_addr"
                else
                    restored=false
                    while [ -s "$STACK_FILE" ]; do
                        addr=$(tail -n 1 "$STACK_FILE")
                        sed -i '$d' "$STACK_FILE"

                        if [[ -n "$addr" ]] && window_exists "$addr"; then
                            dispatch_move_to_ws "$target_ws" "$addr"
                            restored=true
                            break
                        fi
                    done

                    if [ "$restored" = false ]; then
                        notify-send -a "Minimize" -u low "Stack is empty"
                    fi
                fi
            fi
            ;;

        "toggle")
            hyprctl dispatch 'hl.dsp.workspace.toggle_special("minimize")'
            ;;
    esac

) 200>"$LOCK_FILE"
