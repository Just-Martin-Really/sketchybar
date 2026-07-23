#!/bin/sh

# Instantaneous CPU usage as (100 - idle). top's first sample is a lifetime
# average, so take two samples and read the second, which covers the live
# interval. (ps -o %cpu sums per-process lifetime averages and drifts low.)
CPU_USAGE="$(top -l 2 -n 0 2>/dev/null | awk '/CPU usage/ { l=$0 } END {
  n=split(l, a, " ")
  for (i=1; i<=n; i++) if (a[i]=="idle") printf "%d", 100 - a[i-1]
}')"

sketchybar --set "$NAME" label="${CPU_USAGE}%"
