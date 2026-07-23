#!/bin/sh

# Total physical memory in bytes.
TOTAL_BYTES="$(sysctl -n hw.memsize)"
TOTAL_GB_NUM="$(awk -v b="$TOTAL_BYTES" 'BEGIN { printf "%d", b / 1024 / 1024 / 1024 }')"

# Used memory (active + wired + compressed) from a single vm_stat call.
USED_GB="$(vm_stat | awk '
  /page size of/                 { ps=$8 }
  /Pages active/                 { gsub(/\./,"",$3); a=$3 }
  /Pages wired down/             { gsub(/\./,"",$4); w=$4 }
  /Pages occupied by compressor/ { gsub(/\./,"",$5); c=$5 }
  END { printf "%.1f", ((a + w + c) * ps) / 1024 / 1024 / 1024 }
')"

sketchybar --set "$NAME" label="${USED_GB}/${TOTAL_GB_NUM}G"
