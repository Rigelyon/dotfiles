#!/usr/bin/env bash

SAVE_DIR="$HOME/Videos/Recordings"
mkdir -p "$SAVE_DIR"

TMP_LATEST="/tmp/recording_latest.txt"
TMP_TIMER_PID="/tmp/recording_timer.pid"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Screen recording script using wf-recorder.

Options:
  -m, --mode <MODE>   Recording mode. Available modes:
                        fullscreen  - Record full screen
                        area        - Record a specific area
                        active      - Record the active window
  -s, --stop          Stop the current recording
  -h, --help          Show this help message
EOF
}

stop_recording() {
    if ! pgrep -x "wf-recorder" > /dev/null; then
        return 1
    fi

    if [ -f "$TMP_TIMER_PID" ]; then
        TIMER_PID=$(cat "$TMP_TIMER_PID")
        pkill -P "$TIMER_PID" 2>/dev/null || true
        kill "$TIMER_PID" 2>/dev/null || true
        rm -f "$TMP_TIMER_PID"
    fi

    pkill -INT -x wf-recorder
    pkill -f "quickshell.*recording-overlay\.qml" || true

    while pgrep -x "wf-recorder" > /dev/null; do
        sleep 0.1
    done

    if [ ! -f "$TMP_LATEST" ]; then
        notify-send -a "Screenrecord" -u critical "Error" "Temporary file not found."
        return 1
    fi

    FINAL_FILE=$(cat "$TMP_LATEST")

    if [ ! -f "$FINAL_FILE" ]; then
        notify-send -a "Screenrecord" -u critical "Error" "Recording file not found in $FINAL_FILE"
        rm -f "$TMP_LATEST"
        return 1
    fi

    wl-copy -t text/uri-list "file://$FINAL_FILE"

    SAVED_ACTION=$(notify-send -a "Screenrecord" \
        "Recording Saved" \
        "File: $(basename "$FINAL_FILE")" \
        -A "view=View" \
        -A "copy=Copy" \
        -A "delete=Delete")

    if [ "$SAVED_ACTION" = "view" ]; then
        xdg-open "$FINAL_FILE"
    elif [ "$SAVED_ACTION" = "copy" ]; then
        wl-copy -t text/uri-list "file://$FINAL_FILE"
        notify-send -a "Screenrecord" -u low "Copied" "Recording copied to clipboard."
    elif [ "$SAVED_ACTION" = "delete" ]; then
        rm -f "$FINAL_FILE"
        notify-send -a "Screenrecord" -u low "File Deleted" "The saved recording was deleted."
    fi

    rm -f "$TMP_LATEST"
    return 0
}

MODE="fullscreen"
DO_STOP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -t|--time)
            MAX_TIME="$2"
            shift 2
            ;;
        -s|--stop)
            DO_STOP=true
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

if [ "$DO_STOP" = true ]; then
    stop_recording
    exit $?
fi

if pgrep -x "wf-recorder" > /dev/null; then
    stop_recording
    exit $?
fi

FINAL_FILE="$SAVE_DIR/Recording_$(date +'%Y-%m-%d_%H-%M-%S').mp4"
echo "$FINAL_FILE" > "$TMP_LATEST"

QUICKSHELL_FILE="$HOME/.config/quickshell/recording-overlay.qml"
SELECTOR_FILE="$HOME/.config/quickshell/region-selector.qml"

case "$MODE" in
    fullscreen)
        notify-send -a "Screenrecord" -u low "Recording Started" "Fullscreen mode"
        wf-recorder -f "$FINAL_FILE" &
        ;;
    area)
        rm -f /tmp/recording_region.txt

        if [ -f "$SELECTOR_FILE" ]; then
            quickshell --path "$SELECTOR_FILE" > /tmp/quickshell_overlay.log 2>&1
        else
            geom=$(slurp)
            [ $? -ne 0 ] && { notify-send -a "Screenrecord" -u low "Cancelled" "Area selection cancelled."; rm -f "$TMP_LATEST"; exit 1; }
            echo "$geom" > /tmp/recording_region.txt
        fi

        if [ ! -f /tmp/recording_region.txt ]; then
            notify-send -a "Screenrecord" -u low "Cancelled" "Area selection cancelled."
            rm -f "$TMP_LATEST"
            exit 1
        fi

        geom=$(cat /tmp/recording_region.txt)
        rm -f /tmp/recording_region.txt
        IFS=', x' read -r gx gy gw gh <<< "$geom"

        if [ -f "$QUICKSHELL_FILE" ]; then
            RECORD_X=$gx RECORD_Y=$gy RECORD_W=$gw RECORD_H=$gh quickshell --path "$QUICKSHELL_FILE" > /tmp/quickshell_overlay.log 2>&1 &
        fi

        notify-send -a "Screenrecord" -u low "Recording Started" "Area mode"
        wf-recorder -g "$geom" -f "$FINAL_FILE" &
        ;;
    active)
        active_window=$(hyprctl activewindow -j)
        if [ -z "$active_window" ] || [ "$active_window" = "{}" ]; then
            notify-send -a "Screenrecord" -u critical "Error" "No active window found."
            rm -f "$TMP_LATEST"
            exit 1
        fi
        geom=$(echo "$active_window" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        
        IFS=', x' read -r gx gy gw gh <<< "$geom"
        
        if [ -f "$QUICKSHELL_FILE" ]; then
            RECORD_X=$gx RECORD_Y=$gy RECORD_W=$gw RECORD_H=$gh quickshell --path "$QUICKSHELL_FILE" > /tmp/quickshell_overlay.log 2>&1 &
        fi
        
        notify-send -a "Screenrecord" -u low "Recording Started" "Active window mode"
        wf-recorder -g "$geom" -f "$FINAL_FILE" &
        ;;
    *)
        echo "Invalid mode: $MODE"
        show_help
        rm -f "$TMP_LATEST"
        exit 1
        ;;
esac

if [ -n "$MAX_TIME" ] && [ "$MAX_TIME" -gt 0 ]; then
    (
        sleep "$MAX_TIME"
        if pgrep -x "wf-recorder" > /dev/null; then
            notify-send -a "Screenrecord" -u critical "Time limit reached" "Recording automatically stopped after ${MAX_TIME}s"
            "$0" --stop &
        fi
        rm -f "$TMP_TIMER_PID"
    ) &
    echo $! > "$TMP_TIMER_PID"
fi
