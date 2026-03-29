#!/usr/bin/env bash

SELECTOR_FILE="$HOME/.config/quickshell/region-selector.qml"
REGION_FILE="/tmp/recording_region.txt"

rm -f "$REGION_FILE"

if [ -f "$SELECTOR_FILE" ]; then
    quickshell --path "$SELECTOR_FILE" > /tmp/quickshell_overlay.log 2>&1
else
    geom=$(slurp)
    if [ $? -ne 0 ]; then
        notify-send -a "QR Scanner" -u low "Cancelled" "Area selection cancelled."
        exit 1
    fi
    echo "$geom" > "$REGION_FILE"
fi

if [ ! -f "$REGION_FILE" ]; then
    notify-send -a "QR Scanner" -u low "Cancelled" "Area selection cancelled."
    exit 1
fi

geom=$(cat "$REGION_FILE")
rm -f "$REGION_FILE"

TMP_IMG="/tmp/qr_scan_$(date +%s).png"
if ! grim -g "$geom" "$TMP_IMG"; then
    notify-send -a "QR Scanner" -u critical "Error" "Failed to capture screen area."
    exit 1
fi

qr_text=$(zbarimg -q --raw "$TMP_IMG" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$qr_text" ]; then
    printf "%s" "$qr_text" | wl-copy
    
    if [ ${#qr_text} -gt 150 ]; then
        display_text="${qr_text:0:150}..."
    else
        display_text="$qr_text"
    fi
    
    notify-send -a "QR Scanner" -u normal "QR Code Detected" "Copied to clipboard:\n$display_text"
else
    notify-send -a "QR Scanner" -u normal "No QR Code" "Could not detect any QR code in the selected area."
fi

# 4. Clean up
rm -f "$TMP_IMG"
