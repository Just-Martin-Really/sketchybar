#!/bin/bash
# Background watcher that listens to macOS Control Center status events
# (subsystem com.apple.controlcenter) and writes mic/camera in-use state to
# /tmp/sb_{mic,camera}_state. Triggers sketchybar custom events so the bar
# updates immediately on change.

PIDFILE="/tmp/sketchybar_avwatch.pid"
MIC_STATE="/tmp/sb_mic_state"
CAM_STATE="/tmp/sb_camera_state"

# Kill any previous watcher and orphaned log stream children from prior
# sketchybar reloads. Match by command line so orphans get cleaned up too.
for pid in $(pgrep -f "avwatch.sh" 2>/dev/null); do
  [ "$pid" = "$$" ] && continue
  pkill -P "$pid" 2>/dev/null
  kill "$pid" 2>/dev/null
done
pkill -f 'log stream --style compact --predicate.*controlcenter' 2>/dev/null
sleep 0.2

echo "0" > "$MIC_STATE"
echo "0" > "$CAM_STATE"
echo $$ > "$PIDFILE"

# Set initial state from current Control Center indicators, then stream.
# The compact style emits one event per line; we match Camera/Microphone
# indicator on/off transitions from com.apple.controlcenter activity.
/usr/bin/log stream --style compact --predicate 'subsystem == "com.apple.controlcenter" AND category == "sensor-indicators"' 2>/dev/null \
  | while IFS= read -r line; do
      # We only care about the summary line that lists currently active
      # attributions. It looks like:
      #   ... Sorted active attributions from SystemStatus update: [[cam] App ...] [mic] App ...]
      # Per-indicator markers: [cam] camera, [mic] microphone, [scr] screen rec.
      case "$line" in
        *"Sorted active attributions"*)
          case "$line" in
            *"[cam]"*) NEW_CAM=1 ;;
            *)         NEW_CAM=0 ;;
          esac
          case "$line" in
            *"[mic]"*) NEW_MIC=1 ;;
            *)         NEW_MIC=0 ;;
          esac

          OLD_CAM="$(cat "$CAM_STATE" 2>/dev/null)"
          OLD_MIC="$(cat "$MIC_STATE" 2>/dev/null)"

          if [ "$NEW_CAM" != "$OLD_CAM" ]; then
            echo "$NEW_CAM" > "$CAM_STATE"
            sketchybar --trigger camera_change
          fi
          if [ "$NEW_MIC" != "$OLD_MIC" ]; then
            echo "$NEW_MIC" > "$MIC_STATE"
            sketchybar --trigger mic_change
          fi
          ;;
      esac
    done
