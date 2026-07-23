#!/bin/sh
# Show the focused application's name in the pill.
if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" label="$INFO"
fi
