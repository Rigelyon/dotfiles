#!/usr/bin/env bash

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

WAIT_TIME=9000

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Screenshot script using grim and satty.

Options:
  -m, --mode <MODE>   Screenshot mode. Available modes:
                        fullscreen  - Full screen screenshot
                        area        - Screenshot a specific area (clipboard only)
                        active      - Screenshot the active window
  -h, --help          Show this help message
EOF
}

MODE="fullscreen"

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

if [ "$MODE" = "area" ]; then
    geom=$(slurp)
    if [ $? -ne 0 ]; then
        notify-send -a "Screenshot" "Cancelled" "Area selection cancelled."
        exit 1
    fi

    TMP_FILE="/tmp/screenshot_$(date +%s).png"
    grim -g "$geom" "$TMP_FILE"

    if [ ! -f "$TMP_FILE" ]; then
        notify-send -a "Screenshot" -u critical "Error" "Failed to take screenshot."
        exit 1
    fi

    wl-copy < "$TMP_FILE"

    ACTION=$(timeout "$((WAIT_TIME / 1000))" notify-send -a "Screenshot" \
        -i "$TMP_FILE" \
        "Screenshot Taken" \
        "Saved to clipboard." \
        -t "$WAIT_TIME" \
        -A "save=Save to file" \
        -A "view=View")

    if [ "$ACTION" = "save" ]; then
        FINAL_FILE="$SAVE_DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
        cp "$TMP_FILE" "$FINAL_FILE"
        SAVED_ACTION=$(notify-send -a "Screenshot" \
            -i "$FINAL_FILE" \
            "Screenshot Saved" \
            "File: $(basename "$FINAL_FILE")" \
            -A "view=View" \
            -A "delete=Delete")
        if [ "$SAVED_ACTION" = "view" ]; then
            satty -f "$FINAL_FILE" --output-filename "$FINAL_FILE"
        elif [ "$SAVED_ACTION" = "delete" ]; then
            rm -f "$FINAL_FILE"
            notify-send -a "Screenshot" "File Deleted" "The saved screenshot was deleted."
        fi
    elif [ "$ACTION" = "view" ]; then
        FINAL_FILE="$SAVE_DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
        satty -f "$TMP_FILE" --output-filename "$FINAL_FILE"
    fi

    rm -f "$TMP_FILE"
    exit 0
fi

FINAL_FILE="$SAVE_DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

case "$MODE" in
    fullscreen)
        grim "$FINAL_FILE"
        ;;
    active)
        active_window=$(hyprctl activewindow -j)
        if [ -z "$active_window" ] || [ "$active_window" = "{}" ]; then
            notify-send -a "Screenshot" -u critical "Error" "No active window found."
            exit 1
        fi
        geom=$(echo "$active_window" | jq -r '"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])"')
        grim -g "$geom" "$FINAL_FILE"
        ;;
    *)
        echo "Invalid mode: $MODE"
        show_help
        exit 1
        ;;
esac

if [ ! -f "$FINAL_FILE" ]; then
    notify-send -a "Screenshot" -u critical "Error" "Failed to take screenshot."
    exit 1
fi

wl-copy < "$FINAL_FILE"

ACTION=$(notify-send -a "Screenshot" \
    -i "$FINAL_FILE" \
    "Screenshot Saved" \
    "File: $(basename "$FINAL_FILE")" \
    -A "view=View" \
    -A "delete=Delete")

if [ "$ACTION" = "view" ]; then
    satty -f "$FINAL_FILE" --output-filename "$FINAL_FILE"
elif [ "$ACTION" = "delete" ]; then
    rm -f "$FINAL_FILE"
    notify-send -a "Screenshot" "File Deleted" "The saved screenshot was deleted."
fi