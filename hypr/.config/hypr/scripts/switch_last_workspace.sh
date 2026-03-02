#!/usr/bin/env bash

PREV_FILE="/tmp/hypr_prev_ws"
CURR_FILE="/tmp/hypr_curr_ws"

CURRENT_WS=$(hyprctl activeworkspace -j | jq '.id')

if [ ! -f $CURR_FILE ]; then
    echo $CURRENT_WS > $CURR_FILE
    echo $CURRENT_WS > $PREV_FILE
fi

SAVED_CURR=$(cat $CURR_FILE)

if [ "$CURRENT_WS" != "$SAVED_CURR" ]; then
    echo $SAVED_CURR > $PREV_FILE
    echo $CURRENT_WS > $CURR_FILE
fi

if [ "$1" == "--switch" ]; then
    LAST_WS=$(cat $PREV_FILE)
    hyprctl dispatch workspace $LAST_WS
fi