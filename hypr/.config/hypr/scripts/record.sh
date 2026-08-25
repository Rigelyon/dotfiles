#!/usr/bin/env bash

# GPU Screen Recorder wrapper script for Hyprland
# Supports Fullscreen, Area, Active Window, Audio/Mic mixing, and Instant Replay buffer.

SAVE_DIR="${RECORD_SAVE_DIR:-$HOME/Videos/Recordings}"
mkdir -p "$SAVE_DIR"

TMP_LATEST="/tmp/recording_latest.txt"
TMP_TIMER_PID="/tmp/recording_timer.pid"
TMP_MODE="/tmp/recording_mode.txt"
TMP_GSR_PID="/tmp/recording_gsr.pid"
TMP_REGION="/tmp/recording_region.txt"

QUICKSHELL_OVERLAY_FILE="$HOME/.config/quickshell/recording-overlay.qml"
QUICKSHELL_SELECTOR_FILE="$HOME/.config/quickshell/region-selector.qml"

get_gsr_cmd() {
    if command -v gpu-screen-recorder >/dev/null 2>&1; then
        GSR_CMD=("gpu-screen-recorder")
        return 0
    fi

    if command -v flatpak >/dev/null 2>&1 && flatpak info com.dec05eba.gpu_screen_recorder >/dev/null 2>&1; then
        GSR_CMD=("flatpak" "run" "com.dec05eba.gpu_screen_recorder")
        return 0
    fi

    notify-send -a "Screenrecord" -u critical "Error" "gpu-screen-recorder is not installed (native or flatpak)."
    return 1
}

is_gsr_running() {
    pidof gpu-screen-recorder >/dev/null 2>&1 || pgrep -f '[g]pu-screen-recorder' >/dev/null 2>&1 || pgrep -f '[c]om.dec05eba.gpu_screen_recorder' >/dev/null 2>&1
}

get_status() {
    if ! is_gsr_running; then
        echo "idle"
        return 0
    fi

    if [ -f "$TMP_MODE" ]; then
        cat "$TMP_MODE"
    else
        echo "recording"
    fi
}

cleanup() {
    if ! is_gsr_running; then
        rm -f "$TMP_LATEST" "$TMP_MODE" "$TMP_GSR_PID" "$TMP_TIMER_PID" "$TMP_REGION"
    fi
}
trap cleanup EXIT

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Screen recording script using GPU Screen Recorder.

Options:
  -M, --mode <MODE>       Recording mode. Available modes:
                            fullscreen  - Record focused monitor or full screen (default)
                            area        - Record a specific area
                            active      - Record the active window
  -a, --audio             Record system audio
  -m, --mic               Record microphone audio
  -t, --time <SECONDS>    Auto-stop recording after specified seconds
  -f, --fps <FPS>         Target frame rate (default: 60)
  -k, --codec <CODEC>     Video codec: auto, h264, hevc, av1 (default: auto)
  -ac, --audio-codec <AC> Audio codec: aac, opus, flac (default: aac)
  -q, --quality <QUALITY> Encoding quality: medium, high, very_high, ultra (default: very_high)
  -c, --container <EXT>   Container format: mp4, mkv (default: mp4)
  -r, --replay [SECONDS]  Start Instant Replay buffer mode (default duration: 60s)
  --save-replay           Save current instant replay buffer to file
  -s, --stop              Stop the current recording or replay buffer
  --status                Print current recorder status (idle, recording, replaying)
  -h, --help              Show this help message
EOF
}

stop_recording() {
    # If not running, ensure any leftover quickshell overlay is cleaned up
    if ! is_gsr_running; then
        pkill -f "quickshell.*recording-overlay\.qml" 2>/dev/null || true
        return 1
    fi

    if [ -f "$TMP_TIMER_PID" ]; then
        TIMER_PID=$(cat "$TMP_TIMER_PID")
        pkill -P "$TIMER_PID" 2>/dev/null || true
        kill "$TIMER_PID" 2>/dev/null || true
        rm -f "$TMP_TIMER_PID"
    fi

    pkill -f "quickshell.*recording-overlay\.qml" 2>/dev/null || true

    # Graceful stop via SIGINT to ensure container headers (moov atom) are written cleanly
    pkill -INT -f '[g]pu-screen-recorder' 2>/dev/null || pkill -INT -f '[c]om.dec05eba.gpu_screen_recorder' 2>/dev/null || true

    while is_gsr_running; do
        sleep 0.1
    done

    CURRENT_MODE="recording"
    if [ -f "$TMP_MODE" ]; then
        CURRENT_MODE=$(cat "$TMP_MODE")
    fi

    if [ "$CURRENT_MODE" = "replay" ]; then
        rm -f "$TMP_MODE" "$TMP_LATEST" "$TMP_GSR_PID"
        notify-send -a "Screenrecord" -u low "Instant Replay" "Instant replay buffer stopped."
        return 0
    fi

    if [ ! -f "$TMP_LATEST" ]; then
        notify-send -a "Screenrecord" -u critical "Error" "Temporary file not found."
        rm -f "$TMP_MODE" "$TMP_GSR_PID"
        return 1
    fi

    FINAL_FILE=$(cat "$TMP_LATEST")
    rm -f "$TMP_LATEST" "$TMP_MODE" "$TMP_GSR_PID"

    if [ ! -f "$FINAL_FILE" ]; then
        notify-send -a "Screenrecord" -u critical "Error" "Recording file not found in $FINAL_FILE"
        return 1
    fi

    wl-copy -t text/uri-list "file://$FINAL_FILE" 2>/dev/null || true

    SAVED_ACTION=$(timeout 300 notify-send -a "Screenrecord" \
        "Recording Saved" \
        "File: $(basename "$FINAL_FILE")" \
        -t 10000 \
        -A "view=View" \
        -A "copy=Copy" \
        -A "delete=Delete")

    if [ "$SAVED_ACTION" = "view" ]; then
        xdg-open "$FINAL_FILE" 2>/dev/null || true
    elif [ "$SAVED_ACTION" = "copy" ]; then
        wl-copy -t text/uri-list "file://$FINAL_FILE" 2>/dev/null || true
        notify-send -a "Screenrecord" -u low "Copied" "Recording copied to clipboard."
    elif [ "$SAVED_ACTION" = "delete" ]; then
        rm -f "$FINAL_FILE"
        notify-send -a "Screenrecord" -u low "File Deleted" "The saved recording was deleted."
    fi

    return 0
}

save_replay() {
    if ! is_gsr_running; then
        notify-send -a "Screenrecord" -u critical "Error" "No active replay buffer running."
        return 1
    fi

    # Trigger replay save via SIGUSR1
    pkill -USR1 -f '[g]pu-screen-recorder' 2>/dev/null || pkill -USR1 -f '[c]om.dec05eba.gpu_screen_recorder' 2>/dev/null || true
    sleep 0.6

    # Locate newest replay file in SAVE_DIR
    LATEST_REPLAY=$(find "$SAVE_DIR" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.mkv" \) -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n 1 | cut -f2- -d" ")

    if [ -n "$LATEST_REPLAY" ] && [ -f "$LATEST_REPLAY" ]; then
        wl-copy -t text/uri-list "file://$LATEST_REPLAY" 2>/dev/null || true

        SAVED_ACTION=$(timeout 300 notify-send -a "Screenrecord" \
            "Replay Saved" \
            "File: $(basename "$LATEST_REPLAY")" \
            -t 10000 \
            -A "view=View" \
            -A "copy=Copy" \
            -A "delete=Delete")

        if [ "$SAVED_ACTION" = "view" ]; then
            xdg-open "$LATEST_REPLAY" 2>/dev/null || true
        elif [ "$SAVED_ACTION" = "copy" ]; then
            wl-copy -t text/uri-list "file://$LATEST_REPLAY" 2>/dev/null || true
            notify-send -a "Screenrecord" -u low "Copied" "Replay copied to clipboard."
        elif [ "$SAVED_ACTION" = "delete" ]; then
            rm -f "$LATEST_REPLAY"
            notify-send -a "Screenrecord" -u low "File Deleted" "The saved replay was deleted."
        fi
    else
        notify-send -a "Screenrecord" -u normal "Replay Saved" "Replay buffer saved to $SAVE_DIR"
    fi

    return 0
}

# Default CLI parameters
MODE="fullscreen"
DO_STOP=false
DO_SAVE_REPLAY=false
DO_REPLAY=false
REPLAY_DURATION=60
RECORD_AUDIO=false
RECORD_MIC=false
FPS=60
VIDEO_CODEC="auto"
AUDIO_CODEC="aac"
QUALITY="very_high"
CONTAINER="mp4"
MAX_TIME=""

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
        -f|--fps)
            FPS="$2"
            shift 2
            ;;
        -k|--codec)
            VIDEO_CODEC="$2"
            shift 2
            ;;
        -ac|--audio-codec)
            AUDIO_CODEC="$2"
            shift 2
            ;;
        -q|--quality)
            QUALITY="$2"
            shift 2
            ;;
        -c|--container)
            CONTAINER="$2"
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
        -r|--replay)
            DO_REPLAY=true
            if [[ $# -gt 1 ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
                REPLAY_DURATION="$2"
                shift 2
            else
                shift
            fi
            ;;
        --save-replay)
            DO_SAVE_REPLAY=true
            shift
            ;;
        -s|--stop)
            DO_STOP=true
            shift
            ;;
        --status)
            get_status
            exit 0
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

# Normalize quality string if passed as veryhigh
QUALITY="${QUALITY//veryhigh/very_high}"

if [ "$DO_SAVE_REPLAY" = true ]; then
    save_replay
    exit $?
fi

if [ "$DO_STOP" = true ]; then
    stop_recording
    exit $?
fi

# Toggle behavior: if already recording/replaying, stop it
if is_gsr_running; then
    stop_recording
    exit $?
fi

if ! get_gsr_cmd; then
    exit 1
fi

# Build audio arguments
AUDIO_ARGS=()
if [ "$RECORD_AUDIO" = true ] && [ "$RECORD_MIC" = true ]; then
    AUDIO_ARGS+=("-a" "default_output|default_input")
elif [ "$RECORD_AUDIO" = true ]; then
    AUDIO_ARGS+=("-a" "default_output")
elif [ "$RECORD_MIC" = true ]; then
    AUDIO_ARGS+=("-a" "default_input")
fi

if [ ${#AUDIO_ARGS[@]} -gt 0 ]; then
    AUDIO_ARGS+=("-ac" "$AUDIO_CODEC")
fi

# Build codec arguments
CODEC_ARGS=()
if [ -n "$VIDEO_CODEC" ] && [ "$VIDEO_CODEC" != "auto" ]; then
    CODEC_ARGS+=("-k" "$VIDEO_CODEC")
fi

# Build capture target arguments
CAPTURE_SOURCE=()
case "$MODE" in
    fullscreen)
        FOCUSED_MONITOR=""
        if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
            FOCUSED_MONITOR=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused) | .name' 2>/dev/null || true)
        fi

        if [ -n "$FOCUSED_MONITOR" ] && [ "$FOCUSED_MONITOR" != "null" ]; then
            CAPTURE_SOURCE=("-w" "$FOCUSED_MONITOR")
        else
            CAPTURE_SOURCE=("-w" "screen")
        fi

        if [ -f "$QUICKSHELL_OVERLAY_FILE" ]; then
            RECORD_MODE="fullscreen" quickshell --path "$QUICKSHELL_OVERLAY_FILE" > /tmp/quickshell_overlay.log 2>&1 &
        fi
        ;;

    area)
        rm -f "$TMP_REGION"

        if [ -f "$QUICKSHELL_SELECTOR_FILE" ]; then
            SELECTOR_MODE="Screen Record" quickshell --path "$QUICKSHELL_SELECTOR_FILE" > /tmp/quickshell_overlay.log 2>&1
        elif command -v slurp >/dev/null 2>&1; then
            geom=$(slurp)
            [ $? -ne 0 ] && { notify-send -a "Screenrecord" -u low "Cancelled" "Area selection cancelled."; exit 1; }
            echo "$geom" > "$TMP_REGION"
        else
            notify-send -a "Screenrecord" -u critical "Error" "Neither quickshell region selector nor slurp found."
            exit 1
        fi

        if [ ! -f "$TMP_REGION" ]; then
            notify-send -a "Screenrecord" -u low "Cancelled" "Area selection cancelled."
            exit 1
        fi

        geom=$(cat "$TMP_REGION")
        rm -f "$TMP_REGION"
        IFS=', x' read -r gx gy gw gh <<< "$geom"

        if [ -z "$gx" ] || [ -z "$gy" ] || [ -z "$gw" ] || [ -z "$gh" ]; then
            notify-send -a "Screenrecord" -u critical "Error" "Invalid region coordinates."
            exit 1
        fi

        CAPTURE_SOURCE=("-w" "region" "-region" "${gw}x${gh}+${gx}+${gy}")

        if [ -f "$QUICKSHELL_OVERLAY_FILE" ]; then
            RECORD_X=$gx RECORD_Y=$gy RECORD_W=$gw RECORD_H=$gh quickshell --path "$QUICKSHELL_OVERLAY_FILE" > /tmp/quickshell_overlay.log 2>&1 &
        fi
        ;;

    active)
        if ! command -v hyprctl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
            notify-send -a "Screenrecord" -u critical "Error" "hyprctl and jq are required for active window recording."
            exit 1
        fi

        active_window=$(hyprctl activewindow -j 2>/dev/null || true)
        if [ -z "$active_window" ] || [ "$active_window" = "{}" ]; then
            notify-send -a "Screenrecord" -u critical "Error" "No active window found."
            exit 1
        fi

        geom=$(echo "$active_window" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null || true)
        IFS=', x' read -r gx gy gw gh <<< "$geom"

        if [ -z "$gx" ] || [ -z "$gy" ] || [ -z "$gw" ] || [ -z "$gh" ]; then
            notify-send -a "Screenrecord" -u critical "Error" "Could not extract active window dimensions."
            exit 1
        fi

        CAPTURE_SOURCE=("-w" "region" "-region" "${gw}x${gh}+${gx}+${gy}")

        if [ -f "$QUICKSHELL_OVERLAY_FILE" ]; then
            RECORD_X=$gx RECORD_Y=$gy RECORD_W=$gw RECORD_H=$gh quickshell --path "$QUICKSHELL_OVERLAY_FILE" > /tmp/quickshell_overlay.log 2>&1 &
        fi
        ;;

    *)
        echo "Invalid mode: $MODE"
        show_help
        exit 1
        ;;
esac

# Execute GPU Screen Recorder in background
if [ "$DO_REPLAY" = true ]; then
    echo "replay" > "$TMP_MODE"
    "${GSR_CMD[@]}" "${CAPTURE_SOURCE[@]}" "${AUDIO_ARGS[@]}" "${CODEC_ARGS[@]}" -f "$FPS" -q "$QUALITY" -c "$CONTAINER" -r "$REPLAY_DURATION" -ro "$SAVE_DIR" > /tmp/gpu-screen-recorder.log 2>&1 &
    GSR_PID=$!
    echo "$GSR_PID" > "$TMP_GSR_PID"

    sleep 0.4
    if ! is_gsr_running; then
        ERROR_MSG=$(head -n 5 /tmp/gpu-screen-recorder.log 2>/dev/null)
        [ -z "$ERROR_MSG" ] && ERROR_MSG="Failed to start GPU Screen Recorder replay buffer."
        pkill -f "quickshell.*recording-overlay\.qml" 2>/dev/null || true
        notify-send -a "Screenrecord" -u critical "Replay Failed" "$ERROR_MSG"
        rm -f "$TMP_LATEST" "$TMP_MODE" "$TMP_GSR_PID"
        exit 1
    fi

    notify-send -a "Screenrecord" -u low "Instant Replay Started" "Buffering last ${REPLAY_DURATION}s to $SAVE_DIR"
else
    FINAL_FILE="$SAVE_DIR/Recording_$(date +'%Y-%m-%d_%H-%M-%S').$CONTAINER"
    echo "$FINAL_FILE" > "$TMP_LATEST"
    echo "recording" > "$TMP_MODE"
    "${GSR_CMD[@]}" "${CAPTURE_SOURCE[@]}" "${AUDIO_ARGS[@]}" "${CODEC_ARGS[@]}" -f "$FPS" -q "$QUALITY" -c "$CONTAINER" -o "$FINAL_FILE" > /tmp/gpu-screen-recorder.log 2>&1 &
    GSR_PID=$!
    echo "$GSR_PID" > "$TMP_GSR_PID"

    sleep 0.4
    if ! is_gsr_running; then
        ERROR_MSG=$(head -n 5 /tmp/gpu-screen-recorder.log 2>/dev/null)
        [ -z "$ERROR_MSG" ] && ERROR_MSG="Failed to start GPU Screen Recorder."
        pkill -f "quickshell.*recording-overlay\.qml" 2>/dev/null || true
        notify-send -a "Screenrecord" -u critical "Recording Failed" "$ERROR_MSG"
        rm -f "$TMP_LATEST" "$TMP_MODE" "$TMP_GSR_PID"
        exit 1
    fi

    notify-send -a "Screenrecord" -u low "Recording Started" "Mode: $MODE"
fi

if [ -n "$MAX_TIME" ] && [ "$MAX_TIME" -gt 0 ]; then
    (
        sleep "$MAX_TIME"
        if is_gsr_running; then
            notify-send -a "Screenrecord" -u critical "Time limit reached" "Recording automatically stopped after ${MAX_TIME}s"
            "$0" --stop &
        fi
        rm -f "$TMP_TIMER_PID"
    ) &
    echo $! > "$TMP_TIMER_PID"
fi
