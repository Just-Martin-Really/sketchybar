#!/usr/bin/env bash
# Dracula: dark background, purple icons, foreground labels, subtle pill.
# Palette: bg #282a36, current-line #44475a, fg #f8f8f2, purple #bd93f9,
# green #50fa7b, red #ff5555, comment #6272a4.
#
# A theme defines the COLOR_* contract below, then applies the bar-wide values.
# Plugins that need a colour read these variables instead of hardcoding hex,
# so a theme can reach them. Colours are 0xAARRGGBB, alpha first.

COLOR_BAR=0xee282a36        # bar background
COLOR_ICON=0xffbd93f9       # default item icon
COLOR_LABEL=0xfff8f8f2      # default item label
COLOR_PILL=0x8844475a       # focused-app pill background
COLOR_PILL_TEXT=0xfff8f8f2

COLOR_ACCENT=0xffbd93f9     # next meeting, normal
COLOR_URGENT=0xffff5555     # next meeting, within ten minutes
COLOR_MUTED=0xff6272a4      # next meeting, nothing left today
COLOR_ALERT=0xffff5577      # microphone or camera in use

# Applying these is a no-op when sourced by a plugin, because sketchybar --set
# on an item that is not being drawn simply returns.
sketchybar --bar color="$COLOR_BAR"
sketchybar --set '/.*/' icon.color="$COLOR_ICON" label.color="$COLOR_LABEL"
sketchybar --set front_app background.color="$COLOR_PILL" \
                 icon.color="$COLOR_PILL_TEXT" label.color="$COLOR_PILL_TEXT"
