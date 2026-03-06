#!/usr/bin/env bash

music_icon="$HOME/.config/swaync/icons/music.png"

# Play the next track
play_next() {
  playerctl next
}

# Play the previous track
play_previous() {
  playerctl previous
}

# Toggle play/pause
toggle_play_pause() {
  playerctl play-pause
  sleep 0.1
}

# Stop playback
stop_playback() {
  playerctl stop
}


# Get media control action from command line argument
case "$1" in
"--next")
  play_next
  ;;
"--prev")
  play_previous
  ;;
"--pause")
  toggle_play_pause
  ;;
"--stop")
  stop_playback
  ;;
*)
  echo "Usage: $0 [--next|--prev|--pause|--stop]"
  exit 1
  ;;
esac
