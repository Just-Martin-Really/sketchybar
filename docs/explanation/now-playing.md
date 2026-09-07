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

Two further assumptions are baked in. The suffix is the English one, so a Firefox running in another locale needs a different string. The AppleScript targets the process name `firefox`, which both the release and Developer Edition builds use, while the bundle glob `org.mozilla.firefox*` matches either.

## Why the control fields are queried separately

`nowplaying-cli` prints one line per requested key, and the script reads them by position. That is safe only while no value can contain a newline.

A page sets its own `navigator.mediaSession.metadata.title`, and a newline in it is legal. One newline shifts every later field up a line, so `playbackRate` receives the artist and the bundle identifier receives the rate. A crafted title can then skip the Firefox branch and put the page's own text on the bar.

Validating the shifted values does not close this. A title of `EVIL\nInjectedArtist` with artist `1` yields `RATE=1` and `BUNDLE=1.000000`, and a pattern permissive enough to accept a real bundle identifier accepts `1.000000` too.

The fix is to keep page-controlled values out of the query that decides the branch:

```bash
CTRL=$(nowplaying-cli get playbackRate clientBundleIdentifier 2>/dev/null)
```

Neither field comes from the page, so neither can be shifted. Title and artist are fetched only afterwards, in the branch that needs them. A newline there still garbles the label, but it can no longer change which branch runs.

The impact was always display-only. No track data reaches `osascript`, which runs a fixed literal with no interpolation.

## Why the cache is scoped and expires

Firefox tears down its accessibility engine at unpredictable moments, and a read during that window returns nothing. Without a cache the item would flicker off between songs.

An unscoped cache creates worse failures than it prevents. Writing on every path but reading only in the Firefox branch let a Spotify track appear while SoundCloud played. With no expiry, a missing Accessibility grant meant `osascript` failed on every poll and one title sat on the bar permanently.

Each entry now records the owning bundle, and a cached value is reused only when the bundle matches and the file is less than a minute old. A genuinely broken read hides the item instead of lying about it.

The cache is written only after a fresh scrape. Rewriting it from its own contents on every poll would push the modification time forward every three seconds, so the one-minute window would never elapse and the stale title would survive anyway.

The cache lives under `$TMPDIR`, which is per-user and mode 700 on macOS. `/tmp` is mode 1777, and the cached value is a page-controlled string, so a predictable path there allowed a symlink attack against any file the user could write.

## Polling cost

One `nowplaying-cli` call takes roughly 108ms, and the window read roughly 109ms. Browser playback costs one of each, about 220ms every three seconds at `update_freq=3`. Other players cost a second `nowplaying-cli` call instead of the window read, for roughly 216ms. The item ran at one second before the browser fallback existed, which would sustain about 20% of one core.
