#!/usr/bin/env bash

SELECTOR_FILE="$HOME/.config/quickshell/region-selector.qml"
REGION_FILE="/tmp/recording_region.txt"
WAIT_TIME=9000

rm -f "$REGION_FILE"

if [ -f "$SELECTOR_FILE" ]; then
    quickshell --path "$SELECTOR_FILE" > /tmp/quickshell_overlay.log 2>&1
else
    geom=$(slurp)
    if [ $? -ne 0 ]; then
        notify-send -a "OCR Scan" -u low "Cancelled" "Area selection cancelled."
        exit 1
    fi
    echo "$geom" > "$REGION_FILE"
fi

if [ ! -f "$REGION_FILE" ]; then
    notify-send -a "OCR Scan" -u low "Cancelled" "Area selection cancelled."
    exit 1
fi

geom=$(cat "$REGION_FILE")
rm -f "$REGION_FILE"

if [ -z "$geom" ] || [ "$geom" = "0,0 0x0" ]; then
    notify-send -a "OCR Scan" -u low "Cancelled" "Invalid area selected."
    exit 1
fi

TMP_IMG="/tmp/ocr_scan_$(date +%s).png"
if ! grim -g "$geom" -t png "$TMP_IMG"; then
    notify-send -a "OCR Scan" -u critical "Error" "Failed to capture screen area."
    exit 1
fi

notify-send -a "OCR Scan" -u low "Processing" "Extracting text from image..."

PROCESSED_IMG="${TMP_IMG%.*}_processed.png"
if ! magick "$TMP_IMG" -colorspace gray -normalize -sharpen 0x1 "$PROCESSED_IMG"; then
    notify-send -a "OCR Scan" -u critical "Error" "Failed to process image with ImageMagick."
    rm -f "$TMP_IMG"
    exit 1
fi

OUTPUT_BASE="/tmp/ocr_result_$(date +%s)"
OUTPUT_TEXT="$OUTPUT_BASE.txt"

if ! tesseract "$PROCESSED_IMG" "$OUTPUT_BASE" -l eng+ind >/dev/null 2>&1; then
    if ! tesseract "$PROCESSED_IMG" "$OUTPUT_BASE" >/dev/null 2>&1; then
        notify-send -a "OCR Scan" -u critical "Error" "Tesseract failed to extract text."
        rm -f "$TMP_IMG" "$PROCESSED_IMG"
        exit 1
    fi
fi

if [ ! -f "$OUTPUT_TEXT" ]; then
    notify-send -a "OCR Scan" -u critical "Error" "Tesseract failed to generate text output."
    rm -f "$TMP_IMG" "$PROCESSED_IMG"
    exit 1
fi

OCR_CONTENT=$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' < "$OUTPUT_TEXT")

if [ -z "$OCR_CONTENT" ]; then
    notify-send -a "OCR Scan" -i "$TMP_IMG" -u normal "No Text Found" "No text was detected in the selected area."
else
    wl-copy < "$OUTPUT_TEXT"

    PREVIEW=$(head -n 5 "$OUTPUT_TEXT")
    if [ $(wc -l < "$OUTPUT_TEXT") -gt 5 ]; then
        PREVIEW="$PREVIEW
..."
    fi

    ACTION=$(timeout "$((WAIT_TIME / 1000))" notify-send -a "OCR Scan" \
        "Text Extracted" \
        "Copied to clipboard.\n\n<i>${PREVIEW}</i>" \
        -t "$WAIT_TIME" \
        -A "open=Open in Editor")

    if [ "$ACTION" = "open" ]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open "$OUTPUT_TEXT" &
        else
            ${TERMINAL:-kitty} -e ${EDITOR:-micro} "$OUTPUT_TEXT" &
        fi
    fi
fi

rm -f "$TMP_IMG" "$PROCESSED_IMG"
