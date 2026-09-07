#!/usr/bin/env bash
# Current track for the bar.
#
# Playback state and the owning application come from macOS MediaRemote via
# nowplaying-cli, so the item hides whenever nothing is playing.
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

# Query the control fields on their own. A web page sets its own MediaSession
# title and may put a newline in it, which would shift any field read after it.
# Neither of these two comes from the page, so the branch below cannot be
# steered by one. Validating them positionally is only safe because of that.
CTRL=$(nowplaying-cli get playbackRate clientBundleIdentifier 2>/dev/null)
RATE=$(sed -n '1p' <<<"$CTRL" | tr -d '\r\n\t')
BUNDLE=$(sed -n '2p' <<<"$CTRL" | tr -d '\r\n\t')

[[ "$RATE" =~ ^1(\.0+)?$ ]] || hide
[[ "$BUNDLE" =~ ^[A-Za-z][A-Za-z0-9._-]*$ ]] || hide

LABEL=""
FROM_CACHE=0

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
    # the read returns empty. Reuse a recent title from the same player only.
    if [ -z "$LABEL" ] && [ -n "$(find "$CACHE" -mmin "-$CACHE_TTL_MIN" 2>/dev/null)" ]; then
      IFS=$'\t' read -r CACHED_BUNDLE CACHED_LABEL < "$CACHE"
      if [ "$CACHED_BUNDLE" = "$BUNDLE" ]; then
        LABEL="$CACHED_LABEL"
        FROM_CACHE=1
      fi
    fi
    ;;
  *)
    # Only reached for a player that publishes real metadata. A newline in the
    # title can still garble this label, but it can no longer change the branch.
    META=$(nowplaying-cli get title artist 2>/dev/null)
    TITLE=$(sed -n '1p' <<<"$META" | tr -d '\r\n\t')
    ARTIST=$(sed -n '2p' <<<"$META" | tr -d '\r\n\t')
    if [ -n "$TITLE" ] && [ -n "$ARTIST" ]; then
      LABEL="$ARTIST - $TITLE"
    else
      LABEL="$TITLE"
    fi
    ;;
esac

[ -n "$LABEL" ] || hide

# Only refresh the cache on a fresh read. Rewriting it from its own contents
# would push the mtime forward on every poll, so the TTL would never elapse.
if [ "$FROM_CACHE" = "0" ]; then
  [ -L "$CACHE" ] && rm -f "$CACHE"
  printf '%s\t%s\n' "$BUNDLE" "$LABEL" > "$CACHE"
fi

sketchybar --set "$NAME" drawing=on label="$LABEL"
