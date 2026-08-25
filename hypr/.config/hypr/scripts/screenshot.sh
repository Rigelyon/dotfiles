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
  -z, --freeze        Freeze screen during area selection
  -h, --help          Show this help message
EOF
}

MODE="fullscreen"
FREEZE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -z|--freeze)
            FREEZE=true
            shift
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

SELECTOR_FILE="$HOME/.config/quickshell/region-selector.qml"

if [ "$MODE" = "area" ]; then
    rm -f /tmp/recording_region.txt
    FREEZE_FILE="/tmp/screenshot_freeze.png"
    rm -f "$FREEZE_FILE"

    if [ "$FREEZE" = true ]; then
        # Use uncompressed capture (-l 0) for instantaneous screen freeze (<15ms)
        grim -l 0 "$FREEZE_FILE"
    fi

    if [ -f "$SELECTOR_FILE" ]; then
        if [ "$FREEZE" = true ] && [ -f "$FREEZE_FILE" ]; then
            SELECTOR_MODE="Screenshot" FREEZE_IMAGE="$FREEZE_FILE" quickshell --path "$SELECTOR_FILE" > /tmp/quickshell_overlay.log 2>&1
        else
            SELECTOR_MODE="Screenshot" quickshell --path "$SELECTOR_FILE" > /tmp/quickshell_overlay.log 2>&1
        fi
    else
        geom=$(slurp)
        [ $? -ne 0 ] && { notify-send -a "Screenshot" -u low "Cancelled" "Area selection cancelled."; rm -f "$FREEZE_FILE"; exit 1; }
        echo "$geom" > /tmp/recording_region.txt
    fi

    if [ ! -f /tmp/recording_region.txt ]; then
        notify-send -a "Screenshot" -u low "Cancelled" "Area selection cancelled."
        rm -f "$FREEZE_FILE"
        exit 1
    fi

    geom=$(cat /tmp/recording_region.txt)
    rm -f /tmp/recording_region.txt

    TMP_FILE="/tmp/screenshot_$(date +%s).png"
    IFS=', x' read -r gx gy gw gh <<< "$geom"

    CROPPED=false
    if [ "$FREEZE" = true ] && [ -f "$FREEZE_FILE" ]; then
        # Crop directly from the pre-captured freeze frame in ~10ms (zero compositor delay)
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "
from PIL import Image
im = Image.open('$FREEZE_FILE')
x, y, w, h = $gx, $gy, $gw, $gh
crop = im.crop((x, y, x + w, y + h))
crop.save('$TMP_FILE', compress_level=1)
" 2>/dev/null && CROPPED=true
        elif command -v magick >/dev/null 2>&1; then
            magick "$FREEZE_FILE" -crop "${gw}x${gh}+${gx}+${gy}" "$TMP_FILE" 2>/dev/null && CROPPED=true
        elif command -v convert >/dev/null 2>&1; then
            convert "$FREEZE_FILE" -crop "${gw}x${gh}+${gx}+${gy}" "$TMP_FILE" 2>/dev/null && CROPPED=true
        fi
        rm -f "$FREEZE_FILE"
    fi

    if [ "$CROPPED" = false ]; then
        # Allow compositor to unmap overlay surface completely before capture
        sleep 0.05
        grim -l 1 -g "$geom" "$TMP_FILE"
    fi

    if [ ! -f "$TMP_FILE" ]; then
        notify-send -a "Screenshot" -u critical "Error" "Failed to take screenshot."
        exit 1
    fi

    wl-copy < "$TMP_FILE"

    ACTION=$(timeout "$((WAIT_TIME / 1000))" notify-send -a "Screenshot" \
        -i "$TMP_FILE" \
        "Screenshot Taken" \
        "Copied to clipboard without saving to file" \
        -t "$WAIT_TIME" \
        -A "save=Save to file" \
        -A "view=View")

    if [ "$ACTION" = "save" ]; then
        FINAL_FILE="$SAVE_DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
        cp "$TMP_FILE" "$FINAL_FILE"
        SAVED_ACTION=$(timeout 300 notify-send -a "Screenshot" \
            -i "$FINAL_FILE" \
            "Screenshot Saved" \
            "File: $(basename "$FINAL_FILE")" \
            -t "$WAIT_TIME" \
            -A "view=View" \
            -A "delete=Delete")
        if [ "$SAVED_ACTION" = "view" ]; then
            satty -f "$FINAL_FILE" --output-filename "$FINAL_FILE"
        elif [ "$SAVED_ACTION" = "delete" ]; then
            rm -f "$FINAL_FILE"
            notify-send -a "Screenshot" -u low "File Deleted" "The saved screenshot was deleted."
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
        geom=$(echo "$active_window" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
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

ACTION=$(timeout 300 notify-send -a "Screenshot" \
    -i "$FINAL_FILE" \
    "Screenshot Saved" \
    "File: $(basename "$FINAL_FILE")" \
    -t "$WAIT_TIME" \
    -A "view=View" \
    -A "delete=Delete")

if [ "$ACTION" = "view" ]; then
    satty -f "$FINAL_FILE" --output-filename "$FINAL_FILE"
elif [ "$ACTION" = "delete" ]; then
    rm -f "$FINAL_FILE"
    notify-send -a "Screenshot" -u low "File Deleted" "The saved screenshot was deleted."
fi