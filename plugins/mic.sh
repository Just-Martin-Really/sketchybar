#!/usr/bin/env bash
source "$HOME/.config/sketchybar/icons.sh"

STATE="$(cat /tmp/sb_mic_state 2>/dev/null)"
if [ "$STATE" = "1" ]; then
  sketchybar --set "$NAME" icon="$ICON_MIC" icon.color=0xffff5577 drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi
