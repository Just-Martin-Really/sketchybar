#!/usr/bin/env bash
# Nerd Font glyphs as ANSI-C escapes rather than literal characters.
# These codepoints live in the Unicode Private Use Area, which some editors and
# tools strip silently on write. A stripped glyph leaves no error and no visible
# diff, so the escape form is the only reliable way to keep them in git.
ICON_MUSIC=$'\uf001'
ICON_CLOCK=$'\uf017'
ICON_RAM=$'\uf2db'
ICON_CPU=$'\uf4bc'
ICON_NET=$'\uf0ac'
ICON_CAM=$'\uf030'
ICON_MIC=$'\uf130'
ICON_CAL=$'\uf073'
