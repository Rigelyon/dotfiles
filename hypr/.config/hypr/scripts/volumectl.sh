#!/usr/bin/env bash

scriptsDir="$HOME/.config/hypr/scripts"

# Get Volume
get_volume() {
    local is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "true" || echo "false")
    if [[ "$is_muted" == "true" ]]; then
        echo "Muted"
        return
    fi

    local volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
    if [[ "$volume" -eq 0 ]]; then
        echo "Muted"
    else
        echo "$volume %"
    fi
}

# Increase Volume
inc_volume() {
    local muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "true" || echo "false")
    if [ "$muted" == "true" ]; then
        toggle_mute
    else
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "$1"%+
    fi
}

# Decrease Volume
dec_volume() {
    local muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "true" || echo "false")
    if [ "$muted" == "true" ]; then
        toggle_mute
    else
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "$1"%-
    fi
}

# Toggle Mute
toggle_mute() {
	local muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "true" || echo "false")
	if [ "$muted" == "false" ]; then
		wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
	elif [ "$muted" == "true" ]; then
		wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
	fi
}

# Toggle Mic
toggle_mic() {
	local muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo "true" || echo "false")
	if [ "$muted" == "false" ]; then
		wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
	elif [ "$muted" == "true" ]; then
		wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
	fi
}

# Get Microphone Volume
get_mic_volume() {
    local muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo "true" || echo "false")
    if [[ "$muted" == "true" ]]; then
        echo "Muted"
        return
    fi

    local volume=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print int($2 * 100)}')
    if [[ "$volume" -eq 0 ]]; then
        echo "Muted"
    else
        echo "$volume %"
    fi
}

# Increase MIC Volume
inc_mic_volume() {
    local muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo "true" || echo "false")
    if [ "$muted" == "true" ]; then
        toggle_mic
    else
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SOURCE@ 5%+
    fi
}

# Decrease MIC Volume
dec_mic_volume() {
    local muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo "true" || echo "false")
    if [ "$muted" == "true" ]; then
        toggle_mic
    else
        wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-
    fi
}

# Execute accordingly
case "$1" in
"--get")
  get_volume
  ;;
"--inc")
  inc_volume 5
  ;;
"--inc-precise")
  inc_volume 1
  ;;
"--dec")
  dec_volume 5
  ;;
"--dec-precise")
  dec_volume 1
  ;;
"--toggle")
  toggle_mute
  ;;
"--toggle-mic")
  toggle_mic
  ;;
"--get-icon")
  get_icon
  ;;
"--get-mic-icon")
  get_mic_icon
  ;;
"--mic-inc")
  inc_mic_volume
  ;;
"--mic-dec")
  dec_mic_volume
  ;;
*)
  get_volume
  ;;
esac
