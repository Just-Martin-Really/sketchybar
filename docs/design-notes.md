# Design notes

Almost every item in this config has a shape that looks wrong until you know what macOS took away. Apple removed `airport`, deprecated the MediaRemote event that SketchyBar's `media_change` depends on, and made microphone and camera state unpollable on Apple Silicon. Each section below records the constraint, then the workaround it forced.

Read this before changing a plugin. The obvious simplification has usually already been tried.

## Now playing

`plugins/media.sh` reads playback state from macOS MediaRemote through `nowplaying-cli`, then picks a metadata source based on which application owns playback.

One call returns everything the item needs:

```sh
nowplaying-cli get title artist playbackRate clientBundleIdentifier
```

`playbackRate` is `1` while audio plays. The item draws only in that case, so it disappears when you pause instead of showing a stale track.

### Why the metadata source is not uniform

Players disagree about what they publish. Spotify writes real values into MediaRemote, so `title` and `artist` are used directly. Firefox registers for media key control but publishes a placeholder:

```json
"kMRMediaRemoteNowPlayingInfoTitle" : "Firefox Developer Edition is playing media",
"kMRMediaRemoteNowPlayingInfoArtist" : "",
"kMRMediaRemoteNowPlayingInfoClientBundleIdentifier" : "org.mozilla.firefoxdeveloperedition"
```

No track name reaches MediaRemote from a browser. When the bundle identifier matches `org.mozilla.firefox*`, the script falls back to reading the window title, which SoundCloud updates as the track changes.

### Why AppleScript selects the window

The fallback asks AppleScript for one specific window:

```applescript
tell application "System Events" to tell process "firefox" to ¬
  get name of first window whose name ends with "Private Browsing"
```

An earlier version fetched every window name and split the result on commas. That corrupts any title containing a comma, which SoundCloud produces constantly. `Cro - Unendlichkeit (Norda, Master Blaster, Emjo Hypertechno Remix)` arrived at the bar as `Emjo Hypertechno Remix)`. Letting AppleScript filter returns the title intact.

The match assumes the player lives in a dedicated single-tab private window. A window title reflects its active tab, so a multi-tab window would show whatever you last clicked.

### Requirements and cost

Reading another process's window title needs Accessibility permission for SketchyBar, granted in System Settings under Privacy & Security. Without it the Firefox branch returns nothing and only Spotify appears.

Firefox tears down its accessibility engine at unpredictable moments, and a read during that window returns nothing. The last good title is cached at `/tmp/sb_media_last` and reused, so the item does not flicker off between songs.

Each poll costs roughly 108ms for `nowplaying-cli` plus 109ms for the window read. The item runs at `update_freq=3` for that reason. At the old 1-second interval this sustained about 20% of one core.

## Mic and camera indicators

Neither `lsof` nor `ioreg` reports microphone or camera use on Apple Silicon. The working source is Control Center's own logging:

```sh
log stream --style compact \
  --predicate 'subsystem == "com.apple.controlcenter" AND category == "sensor-indicators"'
```

Every privacy-indicator change emits a line beginning `Sorted active attributions from SystemStatus update:`. Active sensors appear as markers in that line: `[cam]`, `[mic]`, `[scr]` for screen recording.

`plugins/avwatch.sh` runs that stream for the life of the bar, writes `0` or `1` to `/tmp/sb_mic_state` and `/tmp/sb_camera_state`, and fires the custom `mic_change` and `camera_change` events declared in `sketchybarrc`. The `mic.sh` and `camera.sh` plugins only read those files, so they stay cheap.

The watcher kills prior instances and orphaned `log stream` children on startup, which makes `sketchybar --reload` safe to run repeatedly.

### Checking whether the watcher is healthy

A single healthy watcher shows **two** `bash avwatch.sh` processes. The second is the subshell bash forks for the `log stream | while read` pipeline, not a duplicate. Counting bash processes will mislead you.

Count the stream children instead. Exactly one is correct:

```sh
pgrep -f 'log stream.*controlcenter' | wc -l
```

Two or more means a previous watcher was orphaned, usually by `brew services restart`. Clean it up:

```sh
pkill -f avwatch.sh; pkill -f 'log stream.*controlcenter'; sketchybar --reload
```

An application that holds screen recording permanently, such as AltTab, keeps `[scr]` active and the macOS privacy dot lit. That is the application, not this config.

## Next meeting

`plugins/next_meeting.sh` queries `icalBuddy` once a minute and shows the next timed event today. The item turns Dracula red when the meeting starts within 10 minutes, and reads `No more meetings today` once the day is clear.

Two flags matter. `icalBuddy` prints the title before the datetime by default, which made the original parser return nothing, so `-po "datetime,title"` forces the order. `-ps "|@|"` sets `@` as the separator, because titles contain almost every other punctuation character.

All-day events are dropped at the source with `-ea`. Holiday, birthday, reminder and task calendars are excluded by name through `-ec`, so a public holiday cannot masquerade as a meeting.

`icalBuddy` reads macOS Calendar through EventKit. It sees Outlook and M365 events only after the Exchange account is added in System Settings under Internet Accounts. Without that, the item stays empty on a work machine and nothing in the config is wrong.

Clicking the item runs `next_meeting_join.sh`, which extracts the first `teams.microsoft.com` link from the event and opens it. It falls back to opening Calendar when no link exists.

## Wi-Fi

`airport` was removed in macOS 14.4 and `wdutil` requires sudo, which is impractical for a process managed by launchd. RSSI comes from `system_profiler SPAirPortDataType` instead, parsed out of the `Signal / Noise` field. That call needs no privileges.

The interface is resolved through `networksetup -listallhardwareports` rather than assumed to be `en0`, with `en0` kept only as a fallback.

SSID is deliberately absent. macOS 14 and later return `<redacted>` without Location Services permission, and granting that to a launchd-managed process is more trouble than the name is worth.

## CPU

`top` reports a lifetime average in its first sample, so `cpu.sh` takes two samples and reads the second:

```sh
top -l 2 -n 0
```

The value shown is `100 - idle`. Summing `ps -o %cpu` was tried and drifts low, because those are per-process lifetime averages rather than a live interval.

## RAM

A single `vm_stat` call supplies active, wired and compressed pages. Their sum times the page size is the used figure. Total physical memory comes from `sysctl -n hw.memsize`.

## Network throughput

`network.sh` reads counters from `netstat -ibn` for `en0` and diffs them against `/tmp/sketchybar_net_en0`, which also stores the timestamp of the previous run.

The formatter pads output to four characters with `printf "%4s"`. Without the padding the label changes width as throughput moves between `300B` and `1.2M`, and every item to the left of it jiggles. Remove the padding only if the font stops being monospaced.

## Icons

Nerd Font glyphs sit in the Unicode Private Use Area, and several editors and tools strip those characters silently on write. A stripped glyph is invisible in a diff and breaks the item with no error.

`icons.sh` therefore defines every glyph as a bash ANSI-C escape:

```sh
ICON_CAL=$'\uf073'
```

The escape is plain ASCII, so it survives any tool. Bash expands it to UTF-8 at runtime. Plugins `source` the file rather than embedding literal glyphs.

To confirm what actually landed in a file, read the bytes:

```sh
hexdump -C icons.sh | head
```

## Themes

A theme is a script, not a data file, because SketchyBar has no notion of a palette. `themes/dracula.sh` re-sets colors on the running bar with three levers: `--bar color`, a wildcard `--set '/.*/'` for the defaults every item inherits, and per-item overrides for anything special such as the `front_app` pill.

Colors use `0xAARRGGBB`, alpha first.

Items are never recreated, so a theme applies instantly with no flicker. The active theme is sourced at the end of `sketchybarrc` and survives reloads.

## Reload, not restart

Use `sketchybar --reload` for configuration changes. It re-sources `sketchybarrc` in place.

Avoid `brew services restart sketchybar` unless something is genuinely broken. It kills the parent process, which can orphan the `log stream` child that `avwatch.sh` owns, and leaves the macOS privacy indicator confused for a moment on Sonoma and later.
