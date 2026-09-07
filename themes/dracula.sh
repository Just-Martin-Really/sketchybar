#!/usr/bin/env bash
# Dracula: dark background, purple icons, foreground labels, subtle pill.
# Palette: bg #282a36, current-line #44475a, fg #f8f8f2, purple #bd93f9,
# green #50fa7b, red #ff5555.
sketchybar --bar color=0xee282a36
sketchybar --set '/.*/' icon.color=0xffbd93f9 label.color=0xfff8f8f2
sketchybar --set front_app background.color=0x8844475a icon.color=0xfff8f8f2 label.color=0xfff8f8f2
