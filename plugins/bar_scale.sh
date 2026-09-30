#!/usr/bin/env bash
# Resize the bar for the display that just became active.
#
# Sizes are points, so identical numbers are physically larger on a less dense
# display: a 36 point bar is 6.1mm on a 150 ppi laptop panel and 9.7mm on a
# 94 ppi monitor. This rescales the bar height, the fonts and the pill height
# from the combined density of the displays that are connected.
#

source "$CONFIG_DIR/sizes.sh"

HELPER_SRC="$CONFIG_DIR/helpers/display_ppi.swift"
HELPER_BIN="$CONFIG_DIR/helpers/display_ppi"

# Built on first use, and again whenever the source changes. Without swiftc the
# bar keeps the sizes sketchybarrc set, which is how it behaved before this
# existed, so a machine without the developer tools is no worse off.
if [ ! -x "$HELPER_BIN" ] || [ "$HELPER_SRC" -nt "$HELPER_BIN" ]; then
  command -v swiftc >/dev/null 2>&1 || exit 0
  swiftc -O "$HELPER_SRC" -o "$HELPER_BIN" >/dev/null 2>&1 || exit 0
fi

# Deliberately not sized for the display that just became active. SketchyBar has
# one global bar height, so following focus would resize the bar on both screens
# every time focus crossed between them, and on a two monitor desk both bars are
# in view. The helper returns a density combined across connected displays, so
# this only moves when the display setup does.
PPI="$("$HELPER_BIN" 2>/dev/null)"
case "$PPI" in ''|*[!0-9]*) exit 0 ;; esac

read -r HEIGHT ICON LABEL BACKGROUND <<EOF
$(LC_ALL=C awk -v ppi="$PPI" -v ref="$REFERENCE_PPI" -v e="$SCALE_EXPONENT" \
      -v lo="$SCALE_MIN" -v hi="$SCALE_MAX" -v h="$BASE_HEIGHT" \
      -v i="$BASE_ICON" -v l="$BASE_LABEL" -v b="$BASE_BACKGROUND" 'BEGIN {
  s = (ppi / ref) ^ e
  if (s < lo) s = lo
  if (s > hi) s = hi
  printf "%d %.1f %.1f %d", int(h * s + 0.5), i * s, l * s, int(b * s + 0.5)
}')
EOF

# An empty value here would not fail: `sketchybar --bar height=` succeeds and
# sets the height to 0, hiding the bar. Every other failure in this script
# leaves the sizes alone, and so must this one.
case "$HEIGHT$BACKGROUND" in ''|*[!0-9]*) exit 0 ;; esac
case "$ICON$LABEL" in ''|*[!0-9.]*) exit 0 ;; esac

# Item fonts are fixed when the item is created, so --default only reaches
# items added after this point and every existing one has to be set by name.
ARGS=(--bar height="$HEIGHT"
      --default icon.font="$ICON_FONT_FACE:$ICON" \
                label.font="$LABEL_FONT_FACE:$LABEL" \
                background.height="$BACKGROUND")

while read -r ITEM; do
  [ -n "$ITEM" ] || continue
  ARGS+=(--set "$ITEM" icon.font="$ICON_FONT_FACE:$ICON" \
                       label.font="$LABEL_FONT_FACE:$LABEL" \
                       background.height="$BACKGROUND")
done <<EOF
$(sketchybar --query bar | awk '
  /"items"/ { inside = 1; next }
  inside && /\]/ { exit }
  inside { gsub(/^[ \t]+|[",]|[ \t]+$/, ""); if (length) print }
')
EOF

sketchybar "${ARGS[@]}"
