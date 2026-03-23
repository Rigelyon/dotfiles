#!/usr/bin/env bash

active_pid=$(hyprctl activewindow | grep -o 'pid: [0-9]*' | cut -d' ' -f2)

if [[ -z "$active_pid" || ! "$active_pid" =~ ^[0-9]+$ ]]; then
  notify-send -a "Kill Active Window" -u low "No active window PID found."
  exit 1
fi

kill "$active_pid"
