#!/usr/bin/env bash
# Open whichever music app is currently playing.

is_playing() {
  local app="$1"
  [ "$(osascript -e "tell application \"$app\" to player state as string" 2>/dev/null)" = "playing" ]
}

if pgrep -x "Spotify" >/dev/null 2>&1 && is_playing Spotify; then
  open -a "Spotify"
elif pgrep -x "Music" >/dev/null 2>&1 && is_playing Music; then
  open -a "Music"
fi
