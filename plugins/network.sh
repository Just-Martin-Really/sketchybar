#!/bin/sh

# Track up/down throughput on en0 between invocations.
IFACE="en0"
STATE_FILE="/tmp/sketchybar_net_${IFACE}"

NOW="$(date +%s)"
read -r IN_BYTES OUT_BYTES <<EOF
$(netstat -ibn | awk -v i="$IFACE" '$1==i && $7 ~ /^[0-9]+$/ { print $7, $10; exit }')
EOF

if [ -z "$IN_BYTES" ] || [ -z "$OUT_BYTES" ]; then
  sketchybar --set "$NAME" label="off"
  exit 0
fi

if [ -f "$STATE_FILE" ]; then
  read -r PREV_TIME PREV_IN PREV_OUT < "$STATE_FILE"
  DT=$(( NOW - PREV_TIME ))
  [ "$DT" -lt 1 ] && DT=1
  DOWN_BPS=$(( (IN_BYTES  - PREV_IN)  / DT ))
  UP_BPS=$(( (OUT_BYTES - PREV_OUT) / DT ))
else
  DOWN_BPS=0
  UP_BPS=0
fi

echo "$NOW $IN_BYTES $OUT_BYTES" > "$STATE_FILE"

# Format bytes/sec as K or M with one decimal where useful.
fmt() {
  awk -v b="$1" 'BEGIN {
    if (b < 1024)             { s = sprintf("%dB",   b) }
    else if (b < 1024*1024)   { s = sprintf("%dK",   b/1024) }
    else                      { s = sprintf("%.1fM", b/1024/1024) }
    printf "%4s", s
  }'
}

DOWN="$(fmt "$DOWN_BPS")"
UP="$(fmt "$UP_BPS")"

sketchybar --set "$NAME" label="↑${UP} ↓${DOWN}"
