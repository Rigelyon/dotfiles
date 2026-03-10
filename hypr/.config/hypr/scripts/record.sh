#!/usr/bin/env bash

SAVE_DIR="$HOME/Videos/Recordings"
mkdir -p "$SAVE_DIR"

TMP_LATEST="/tmp/recording_latest.txt"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Screen recording script using wf-recorder.

Options:
  -m, --mode <MODE>   Recording mode. Available modes:
                        fullscreen  - Record full screen
                        area        - Record a specific area
                        active      - Record the active window
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
        -t|--time)
            MAX_TIME="$2"
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

if pgrep -x "wf-recorder" > /dev/null; then
    # Jika sedang merekam, hentikan rekaman
    pkill -INT -x wf-recorder
    
    # Hentikan overlay quickshell jika ada
    pkill -f "quickshell.*recording-overlay\.qml" || true

    # Tunggu hingga proses wf-recorder benar-benar berhenti
    while pgrep -x "wf-recorder" > /dev/null; do
        sleep 0.1
    done

    if [ ! -f "$TMP_LATEST" ]; then
        notify-send -a "Screenrecord" -u critical "Error" "Data file temporary tidak ditemukan."
        exit 1
    fi

    FINAL_FILE=$(cat "$TMP_LATEST")

    if [ ! -f "$FINAL_FILE" ]; then
        notify-send -a "Screenrecord" -u critical "Error" "File rekaman tidak ditemukan di $FINAL_FILE"
        rm -f "$TMP_LATEST"
        exit 1
    fi

    SAVED_ACTION=$(notify-send -a "Screenrecord" \
        "Recording Saved" \
        "File: $(basename "$FINAL_FILE")" \
        -A "view=View" \
        -A "delete=Delete")

    if [ "$SAVED_ACTION" = "view" ]; then
        xdg-open "$FINAL_FILE"
    elif [ "$SAVED_ACTION" = "delete" ]; then
        rm -f "$FINAL_FILE"
        notify-send -a "Screenrecord" "File Deleted" "The saved recording was deleted."
    fi
    
    rm -f "$TMP_LATEST"
    exit 0
fi

# Jika tidak ada proses wf-recorder berjalan, mulai rekaman
FINAL_FILE="$SAVE_DIR/Recording_$(date +'%Y-%m-%d_%H-%M-%S').mp4"
echo "$FINAL_FILE" > "$TMP_LATEST"

QUICKSHELL_FILE="$HOME/.config/quickshell/recording-overlay.qml"

case "$MODE" in
    fullscreen)
        notify-send -a "Screenrecord" "Recording Started" "Fullscreen mode"
        wf-recorder -f "$FINAL_FILE" &
        ;;
    area)
        geom=$(slurp)
        if [ $? -ne 0 ]; then
            notify-send -a "Screenrecord" "Cancelled" "Area selection cancelled."
            rm -f "$TMP_LATEST"
            exit 1
        fi
        
        # Parse koordinat geometry slurp (X,Y WxH) menjadi gx, gy, gw, gh
        IFS=', x' read -r gx gy gw gh <<< "$geom"
        
        # Jalankan overlay Quickshell jika file ada
        if [ -f "$QUICKSHELL_FILE" ]; then
            RECORD_X=$gx RECORD_Y=$gy RECORD_W=$gw RECORD_H=$gh quickshell --path "$QUICKSHELL_FILE" > /tmp/quickshell_overlay.log 2>&1 &
        fi

        notify-send -a "Screenrecord" "Recording Started" "Area mode"
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
        
        # Parse koordinat geometry (X,Y WxH) menjadi gx, gy, gw, gh
        IFS=', x' read -r gx gy gw gh <<< "$geom"
        
        # Jalankan overlay Quickshell jika file ada
        if [ -f "$QUICKSHELL_FILE" ]; then
            RECORD_X=$gx RECORD_Y=$gy RECORD_W=$gw RECORD_H=$gh quickshell --path "$QUICKSHELL_FILE" > /tmp/quickshell_overlay.log 2>&1 &
        fi
        
        notify-send -a "Screenrecord" "Recording Started" "Active window mode"
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
            # Call this script again to gracefully stop recording and save the file
            "$0" &
        fi
    ) &
fi
