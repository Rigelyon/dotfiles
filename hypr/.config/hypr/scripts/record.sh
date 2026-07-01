#!/usr/bin/env bash

SAVE_DIR="$HOME/Videos/Recordings"
mkdir -p "$SAVE_DIR"

TMP_LATEST="/tmp/recording_latest.txt"
TMP_TIMER_PID="/tmp/recording_timer.pid"
TMP_AUDIO_MODULES="/tmp/recording_audio_modules.txt"
TMP_MIC_STATE="/tmp/recording_mic_state.txt"

cleanup() {
    if ! pgrep -x "wf-recorder" > /dev/null; then
        if [ -f "$TMP_AUDIO_MODULES" ]; then
            while read -r module_id; do
                if [ -n "$module_id" ]; then
                    pactl unload-module "$module_id" 2>/dev/null || true
                fi
            done < "$TMP_AUDIO_MODULES"
            rm -f "$TMP_AUDIO_MODULES"
        fi

        if [ -f "$TMP_MIC_STATE" ]; then
            MIC_STATE=$(cat "$TMP_MIC_STATE")
            if [ "$MIC_STATE" = "muted" ]; then
                wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1 2>/dev/null || true
            else
                wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0 2>/dev/null || true
            fi
            rm -f "$TMP_MIC_STATE"
        fi
        rm -f "$TMP_LATEST"
    fi
}
trap cleanup EXIT

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Screen recording script using wf-recorder.

Options:
  -M, --mode <MODE>   Recording mode. Available modes:
                        fullscreen  - Record full screen
                        area        - Record a specific area
                        active      - Record the active window
  -a, --audio         Record system audio
  -m, --mic           Record microphone audio
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

    if [ -f "$TMP_AUDIO_MODULES" ]; then
        while read -r module_id; do
            if [ -n "$module_id" ]; then
                pactl unload-module "$module_id" 2>/dev/null || true
            fi
        done < "$TMP_AUDIO_MODULES"
        rm -f "$TMP_AUDIO_MODULES"
    fi

    if [ -f "$TMP_MIC_STATE" ]; then
        MIC_STATE=$(cat "$TMP_MIC_STATE")
        if [ "$MIC_STATE" = "muted" ]; then
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1 2>/dev/null || true
        else
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0 2>/dev/null || true
        fi
        rm -f "$TMP_MIC_STATE"
    fi

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

    SAVED_ACTION=$(timeout 300 notify-send -a "Screenrecord" \
        "Recording Saved" \
        "File: $(basename "$FINAL_FILE")" \
        -t 10000 \
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
RECORD_AUDIO=false
RECORD_MIC=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -M|--mode)
            MODE="$2"
            shift 2
            ;;
        -t|--time)
            MAX_TIME="$2"
            shift 2
            ;;
        -a|--audio)
            RECORD_AUDIO=true
            shift
            ;;
        -m|--mic)
            RECORD_MIC=true
            shift
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

AUDIO_ARGS=""
if [ "$RECORD_AUDIO" = true ] && [ "$RECORD_MIC" = true ]; then
    if ! command -v pactl >/dev/null 2>&1; then
        notify-send -a "Screenrecord" -u critical "Error" "pactl (pulseaudio-utils) diperlukan untuk merekam audio dan mic bersamaan."
        rm -f "$TMP_LATEST"
        exit 1
    fi

    SINK_ID=$(pactl load-module module-null-sink sink_name=record-combined media.class=Audio/Sink sink_properties=device.description="Record_Combined_Sink")
    if [ -z "$SINK_ID" ]; then
        notify-send -a "Screenrecord" -u critical "Error" "Gagal membuat virtual audio sink."
        rm -f "$TMP_LATEST"
        exit 1
    fi
    echo "$SINK_ID" >> "$TMP_AUDIO_MODULES"

    DEFAULT_SINK=""
    if command -v wpctl >/dev/null 2>&1; then
        DEFAULT_SINK=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | awk -F '"' '/node.name/ {print $2}')
    fi
    if [ -z "$DEFAULT_SINK" ] && command -v pactl >/dev/null 2>&1; then
        DEFAULT_SINK=$(pactl get-default-sink)
    fi
    if [ -z "$DEFAULT_SINK" ]; then
        DEFAULT_SINK="@DEFAULT_AUDIO_SINK@"
    fi

    DEFAULT_SOURCE=""
    if command -v wpctl >/dev/null 2>&1; then
        DEFAULT_SOURCE=$(wpctl inspect @DEFAULT_AUDIO_SOURCE@ | awk -F '"' '/node.name/ {print $2}')
    fi
    if [ -z "$DEFAULT_SOURCE" ] && command -v pactl >/dev/null 2>&1; then
        DEFAULT_SOURCE=$(pactl get-default-source)
    fi
    if [ -z "$DEFAULT_SOURCE" ]; then
        DEFAULT_SOURCE="@DEFAULT_AUDIO_SOURCE@"
    fi

    LOOP_SYS_ID=$(pactl load-module module-loopback source="${DEFAULT_SINK}.monitor" sink="record-combined" latency_msec=100)
    if [ -n "$LOOP_SYS_ID" ]; then
        echo "$LOOP_SYS_ID" >> "$TMP_AUDIO_MODULES"
    fi

    LOOP_MIC_ID=$(pactl load-module module-loopback source="${DEFAULT_SOURCE}" sink="record-combined" latency_msec=100)
    if [ -n "$LOOP_MIC_ID" ]; then
        echo "$LOOP_MIC_ID" >> "$TMP_AUDIO_MODULES"
    fi

    AUDIO_ARGS="--audio=record-combined.monitor"
elif [ "$RECORD_AUDIO" = true ]; then
    if command -v wpctl >/dev/null 2>&1; then
        SINK_NAME=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | awk -F '"' '/node.name/ {print $2}')
        if [ -n "$SINK_NAME" ]; then
            AUDIO_ARGS="--audio=${SINK_NAME}.monitor"
        else
            AUDIO_ARGS="--audio"
        fi
    elif command -v pactl >/dev/null 2>&1; then
        SINK_NAME=$(pactl get-default-sink)
        if [ -n "$SINK_NAME" ]; then
            AUDIO_ARGS="--audio=${SINK_NAME}.monitor"
        else
            AUDIO_ARGS="--audio"
        fi
    else
        AUDIO_ARGS="--audio"
    fi
elif [ "$RECORD_MIC" = true ]; then
    AUDIO_ARGS="--audio"
fi

QUICKSHELL_FILE="$HOME/.config/quickshell/recording-overlay.qml"
SELECTOR_FILE="$HOME/.config/quickshell/region-selector.qml"

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q '\[MUTED\]'; then
    echo "muted" > "$TMP_MIC_STATE"
else
    echo "unmuted" > "$TMP_MIC_STATE"
fi
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1 2>/dev/null || true

case "$MODE" in
    fullscreen)
        if [ -f "$QUICKSHELL_FILE" ]; then
            RECORD_MODE="fullscreen" quickshell --path "$QUICKSHELL_FILE" > /tmp/quickshell_overlay.log 2>&1 &
        fi
        # notify-send -a "Screenrecord" -u low "Recording Started" "Fullscreen mode"
        wf-recorder $AUDIO_ARGS -f "$FINAL_FILE" &
        ;;
    area)
        rm -f /tmp/recording_region.txt

        if [ -f "$SELECTOR_FILE" ]; then
            SELECTOR_MODE="Screen Record" quickshell --path "$SELECTOR_FILE" > /tmp/quickshell_overlay.log 2>&1
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

        # notify-send -a "Screenrecord" -u low "Recording Started" "Area mode"
        wf-recorder $AUDIO_ARGS -g "$geom" -f "$FINAL_FILE" &
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
        
        # notify-send -a "Screenrecord" -u low "Recording Started" "Active window mode"
        wf-recorder $AUDIO_ARGS -g "$geom" -f "$FINAL_FILE" &
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
