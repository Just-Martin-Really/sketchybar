#!/usr/bin/env bash
# Resolves the active theme and exports its colour variables.
#
# A local override wins when present, so a private palette can live on the
# machine without being tracked here. Fall back to the shipped default.
# Both sketchybarrc and any plugin that needs a colour source this file.

_SB_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

if [ -f "$_SB_DIR/themes/local.sh" ]; then
  source "$_SB_DIR/themes/local.sh"
else
  source "$_SB_DIR/themes/dracula.sh"
fi
