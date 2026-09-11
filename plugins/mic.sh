#!/usr/bin/env bash
source "$HOME/.config/sketchybar/icons.sh"
# Alert colour comes from the active theme, not hardcoded here.
source "$HOME/.config/sketchybar/themes/active.sh" >/dev/null 2>&1

STATE="$(cat /tmp/sb_mic_state 2>/dev/null)"
if [ "$STATE" = "1" ]; then
  sketchybar --set "$NAME" icon="$ICON_MIC" icon.color="$COLOR_ALERT" drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi
