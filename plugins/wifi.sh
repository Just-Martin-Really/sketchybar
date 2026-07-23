#!/bin/sh

# Wi-Fi signal strength in dBm. airport was removed on macOS 14.4+ and wdutil
# needs sudo, so RSSI now comes from system_profiler (no privileges required).
# The Wi-Fi interface is resolved dynamically rather than assuming en0.
WIFI_DEV="$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{getline; print $2; exit}')"
[ -z "$WIFI_DEV" ] && WIFI_DEV="en0"

if ! ifconfig "$WIFI_DEV" 2>/dev/null | grep -q "status: active"; then
  sketchybar --set "$NAME" icon="󰖪" label=""
  exit 0
fi

RSSI="$(system_profiler SPAirPortDataType 2>/dev/null | awk -F': ' '/Signal \/ Noise/ {split($2, s, " "); print s[1]; exit}')"

if [ -n "$RSSI" ]; then
  sketchybar --set "$NAME" icon="󰖩" label="${RSSI}dBm"
else
  sketchybar --set "$NAME" icon="󰖩" label=""
fi
