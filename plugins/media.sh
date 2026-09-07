#!/usr/bin/env bash
# Current track for the bar.
#
# Playback state and the owning application always come from macOS MediaRemote
# via nowplaying-cli, so the item hides whenever nothing is playing.
#
# The metadata source then depends on the player. Every player except Firefox
# publishes real values to MediaRemote and is read directly. Firefox publishes
# a placeholder title with an empty artist, so its track name is scraped from
# the title of the dedicated single-tab private window instead.

# $TMPDIR is per-user and mode 700 on macOS. /tmp is world-writable, and this
# cache holds a page-controlled string, so it must not live there.
CACHE="${TMPDIR:-/tmp}/sb_media_last"
CACHE_TTL_MIN=1
PB_SUFFIX=$' \u2014 Private Browsing'

hide() { sketchybar --set "$NAME" drawing=off; exit 0; }

if ! command -v nowplaying-cli >/dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=on label="nowplaying-cli missing"
  exit 0
fi

NP=$(nowplaying-cli get title artist playbackRate clientBundleIdentifier 2>/dev/null)
TITLE=$(sed -n '1p' <<<"$NP" | tr -d '\r\n\t')
ARTIST=$(sed -n '2p' <<<"$NP" | tr -d '\r\n\t')
RATE=$(sed -n '3p' <<<"$NP" | tr -d '\r\n\t')
BUNDLE=$(sed -n '4p' <<<"$NP" | tr -d '\r\n\t')

# A web page sets its own MediaSession title and may put a newline in it, which
# shifts every later field up a line. Validate the two control fields instead of
# trusting their position.
[[ "$RATE" =~ ^1(\.0+)?$ ]] || hide
[[ "$BUNDLE" =~ ^[A-Za-z0-9._-]+$ ]] || hide

LABEL=""
case "$BUNDLE" in
  org.mozilla.firefox*)
    # AppleScript selects the window. Splitting a window list on commas corrupts
    # any title containing one, which SoundCloud titles often do.
    LABEL=$(osascript -e 'tell application "System Events" to tell process "firefox" to get name of first window whose name ends with "Private Browsing"' 2>/dev/null)
    case "$LABEL" in
      *"$PB_SUFFIX") LABEL="${LABEL%"$PB_SUFFIX"}" ;;
      *)             LABEL="" ;;
    esac
    # Firefox tears down its accessibility engine at unpredictable moments and
    # the read returns empty. Reuse a recent title from the same player only, so
    # neither a stale track nor another app's track can sit on the bar.
    if [ -z "$LABEL" ] && [ -n "$(find "$CACHE" -mmin "-$CACHE_TTL_MIN" 2>/dev/null)" ]; then
      IFS=$'\t' read -r CACHED_BUNDLE CACHED_LABEL < "$CACHE"
      [ "$CACHED_BUNDLE" = "$BUNDLE" ] && LABEL="$CACHED_LABEL"
    fi
    ;;
  *)
    if [ -n "$TITLE" ] && [ -n "$ARTIST" ]; then
      LABEL="$ARTIST - $TITLE"
    else
      LABEL="$TITLE"
    fi
    ;;
esac

[ -n "$LABEL" ] || hide

[ -L "$CACHE" ] && rm -f "$CACHE"
printf '%s\t%s\n' "$BUNDLE" "$LABEL" > "$CACHE"
sketchybar --set "$NAME" drawing=on label="$LABEL"
