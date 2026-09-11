#!/usr/bin/env bash
# Tokyo Night: deep navy bar, blue icons, lavender pill.
# Palette: bg #1a1b26, fg #c0caf5, blue #7aa2f7, purple #bb9af7,
# red #f7768e, comment #565f89.
# Defines the same COLOR_* contract as every theme here; see dracula.sh.

COLOR_BAR=0xee1a1b26
COLOR_ICON=0xff7aa2f7
COLOR_LABEL=0xffa9b1d6
COLOR_PILL=0x66bb9af7
COLOR_PILL_TEXT=0xffc0caf5

COLOR_ACCENT=0xff7aa2f7
COLOR_URGENT=0xfff7768e
COLOR_MUTED=0xff565f89
COLOR_ALERT=0xfff7768e

sketchybar --bar color="$COLOR_BAR"
sketchybar --set '/.*/' icon.color="$COLOR_ICON" label.color="$COLOR_LABEL"
sketchybar --set front_app background.color="$COLOR_PILL" \
                 icon.color="$COLOR_PILL_TEXT" label.color="$COLOR_PILL_TEXT"
