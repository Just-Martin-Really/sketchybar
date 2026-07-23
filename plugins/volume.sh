#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "mouse.scrolled" ]; then
  CUR="$(osascript -e 'output volume of (get volume settings)')"
  VOLUME="$(awk -v c="$CUR" -v d="$SCROLL_DELTA" 'BEGIN { s = (d > 0 ? -5 : 5); n = c + s; if (n < 0) n = 0; if (n > 100) n = 100; printf "%d", n }')"
  osascript -e "set volume output volume $VOLUME"
elif [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
fi

if [ -n "$VOLUME" ]; then

  case "$VOLUME" in
    [6-9][0-9]|100) ICON="󰕾"
    ;;
    [3-5][0-9]) ICON="󰖀"
    ;;
    [1-9]|[1-2][0-9]) ICON="󰕿"
    ;;
    *) ICON="󰖁"
  esac

  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%"
fi
