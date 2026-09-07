# How the now-playing item works

See also: [macOS constraints](macos-constraints.md) · [Bar items](../reference/bar-items.md) · [Dependencies and permissions](../reference/dependencies.md)

The item reads playback state from macOS MediaRemote, then picks a metadata source based on which application owns playback. Two sources exist because players disagree about what they publish.

## Why state and metadata come from different places

A single call supplies everything the item needs to decide:

```bash
nowplaying-cli get title artist playbackRate clientBundleIdentifier
```

`playbackRate` is `1` while audio plays. The item draws only in that case, so pausing hides it rather than leaving a stale track on the bar.

Spotify writes real values into MediaRemote, so its title and artist are used directly. Firefox registers for media key control but publishes a placeholder:

```json
{
  "kMRMediaRemoteNowPlayingInfoTitle": "Firefox Developer Edition is playing media",
  "kMRMediaRemoteNowPlayingInfoArtist": "",
  "kMRMediaRemoteNowPlayingInfoClientBundleIdentifier": "org.mozilla.firefoxdeveloperedition"
}
```

No track name reaches MediaRemote from a browser. When the bundle identifier matches `org.mozilla.firefox*`, the track comes from the window title instead, which SoundCloud rewrites as the track changes.

## Why AppleScript picks the window

The fallback asks for one specific window rather than fetching them all:

```applescript
tell application "System Events" to tell process "firefox" to ¬
  get name of first window whose name ends with "Private Browsing"
```

An earlier version fetched every window name and split the result on commas. AppleScript returns a comma-separated list, so any title containing a comma was shredded. `Cro - Unendlichkeit (Norda, Master Blaster, Emjo Hypertechno Remix)` reached the bar as `Emjo Hypertechno Remix)`. Letting AppleScript filter returns the title intact.

The match assumes the player occupies a dedicated single-tab private window. A window title reflects its active tab, so a multi-tab window would show whatever was last clicked.

## Why fields are validated instead of trusted

Fields arrive as four lines and are read by position. That is safe only while every value is single-line.

A page sets its own `navigator.mediaSession.metadata.title`, and a newline in it is legal. One newline shifts every later field up a line, so `playbackRate` receives the artist and the bundle identifier receives the rate. A crafted title can bypass the Firefox branch entirely and put arbitrary text on the bar.

Both control fields are therefore checked before use:

```bash
[[ "$RATE" =~ ^1(\.0+)?$ ]] || hide
[[ "$BUNDLE" =~ ^[A-Za-z0-9._-]+$ ]] || hide
```

The impact was always display-only. No track data reaches `osascript`, which runs a fixed literal with no interpolation.

## Why the cache is scoped and expires

Firefox tears down its accessibility engine at unpredictable moments, and a read during that window returns nothing. Without a cache the item would flicker off between songs.

An unscoped cache creates worse failures than it prevents. Writing on every path but reading only in the Firefox branch let a Spotify track appear while SoundCloud played. With no expiry, a missing Accessibility grant meant `osascript` failed on every poll and one title sat on the bar permanently.

Each entry now records the owning bundle, and a cached value is reused only when the bundle matches and the file is less than a minute old. A genuinely broken read hides the item instead of lying about it.

The cache lives under `$TMPDIR`, which is per-user and mode 700 on macOS. `/tmp` is mode 1777, and the cached value is a page-controlled string, so a predictable path there allowed a symlink attack against any file the user could write.

## Polling cost

One `nowplaying-cli` call takes roughly 108ms, and the window read roughly 109ms. At `update_freq=3` that is about 220ms of work every three seconds. The item ran at one second before the browser fallback existed, which would sustain about 20% of one core.
