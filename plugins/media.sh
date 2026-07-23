#!/usr/bin/env bash
# Poll Spotify and Apple Music for current playback. One osascript call per
# app instead of three, so 1-second polling stays cheap.

LABEL=""

query() {
  local app="$1"
  osascript -e "tell application \"$app\" to (player state as string) & \"|\" & (name of current track) & \"|\" & (artist of current track)" 2>/dev/null
}

parse() {
  local raw="$1"
  local state title artist
  IFS='|' read -r state title artist <<<"$raw"
  [ "$state" = "playing" ] && [ -n "$title" ] || return 1
  if [ -n "$artist" ]; then LABEL="$artist - $title"; else LABEL="$title"; fi
  return 0
}

if pgrep -x "Spotify" >/dev/null 2>&1; then
  parse "$(query Spotify)"
fi
if [ -z "$LABEL" ] && pgrep -x "Music" >/dev/null 2>&1; then
  parse "$(query Music)"
fi

if [ -n "$LABEL" ]; then
  sketchybar --set "$NAME" drawing=on label="$LABEL"
else
  sketchybar --set "$NAME" drawing=off
fi
