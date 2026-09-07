#!/usr/bin/env bash
# Current track for the bar.
#
# Metadata source depends on the player, they expose different things:
#   Spotify - publishes real metadata to macOS MediaRemote, read it directly.
#   Firefox - publishes only "... is playing media", so fall back to the title
#             of the dedicated single-tab SoundCloud private window.
# Playback state always comes from MediaRemote, so the item hides when paused.

CACHE="/tmp/sb_media_last"
PB_SUFFIX=$' — Private Browsing'

NP=$(nowplaying-cli get title artist playbackRate clientBundleIdentifier 2>/dev/null)
TITLE=$(sed -n '1p' <<<"$NP")
ARTIST=$(sed -n '2p' <<<"$NP")
RATE=$(sed -n '3p' <<<"$NP")
BUNDLE=$(sed -n '4p' <<<"$NP")

LABEL=""
if [ "$RATE" = "1" ]; then
  case "$BUNDLE" in
    org.mozilla.firefox*)
      # Let AppleScript pick the window. Splitting a window list on commas
      # corrupts any title that contains one, which SoundCloud titles often do.
      LABEL=$(osascript -e 'tell application "System Events" to tell process "firefox" to get name of first window whose name ends with "Private Browsing"' 2>/dev/null)
      LABEL="${LABEL%$PB_SUFFIX}"
      # Firefox drops its accessibility engine at random, giving an empty read.
      # Reuse the last good title rather than flickering the item off.
      [ -z "$LABEL" ] && LABEL=$(cat "$CACHE" 2>/dev/null)
      ;;
    *)
      [ -n "$ARTIST" ] && LABEL="$ARTIST - $TITLE" || LABEL="$TITLE"
      ;;
  esac
fi

if [ -n "$LABEL" ]; then
  printf '%s' "$LABEL" > "$CACHE"
  sketchybar --set "$NAME" drawing=on label="$LABEL"
else
  sketchybar --set "$NAME" drawing=off
fi
