#!/usr/bin/env bash
# Focus whichever application currently owns playback.
#
# The owner comes from MediaRemote, so this follows the same player the bar
# label does, including browsers. Falling back to a fixed app list would miss
# every player except Spotify and Music.

BUNDLE=$(nowplaying-cli get clientBundleIdentifier 2>/dev/null | tr -d '\r\n\t')

if [[ "$BUNDLE" =~ ^[A-Za-z0-9._-]+$ ]] && open -b "$BUNDLE" 2>/dev/null; then
  exit 0
fi

# MediaRemote reported nothing usable. Fall back to a running known player.
for app in Spotify Music; do
  if pgrep -x "$app" >/dev/null 2>&1; then
    open -a "$app"
    exit 0
  fi
done
