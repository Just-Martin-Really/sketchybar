# macOS constraints

See also: [How the now-playing item works](now-playing.md) · [Bar items](../reference/bar-items.md) · [Fix the mic and camera watcher](../how-to/fix-the-mic-camera-watcher.md)

Apple removed or restricted the API behind several of these items. Each section names the constraint, then the workaround it forced.

## Microphone and camera cannot be polled

Neither `lsof` nor `ioreg` reports microphone or camera use on Apple Silicon. The working source is Control Center's own logging:

```bash
log stream --style compact \
  --predicate 'subsystem == "com.apple.controlcenter" AND category == "sensor-indicators"'
```

Every privacy-indicator change emits a line beginning `Sorted active attributions from SystemStatus update:`. Active sensors appear as markers in that line: `[cam]` for camera, `[mic]` for microphone, `[scr]` for screen recording.

`plugins/avwatch.sh` runs that stream for the life of the bar, writes `0` or `1` to two state files, and fires the custom `mic_change` and `camera_change` events. The `mic.sh` and `camera.sh` plugins only read the files, which keeps them cheap enough to run on an event rather than a timer.

An application holding screen recording permanently, such as AltTab, keeps `[scr]` active and the macOS privacy dot lit. That is the application's doing, not this config's.

## Wi-Fi SSID is redacted and airport is gone

`airport` was removed in macOS 14.4. `wdutil` still reports signal strength but requires sudo, which is impractical for a process managed by launchd.

RSSI therefore comes from `system_profiler SPAirPortDataType`, parsed out of the `Signal / Noise` field. That call needs no privileges. The interface is resolved through `networksetup -listallhardwareports` rather than assumed to be `en0`, with `en0` kept only as a fallback.

SSID is deliberately absent. macOS 14 and later return `<redacted>` without Location Services permission, and granting that to a launchd-managed process is more trouble than the name is worth.

## Calendar access runs through EventKit

`icalBuddy` reads macOS Calendar through EventKit, so it sees only what Calendar has synced. Outlook and Microsoft 365 events appear once the Exchange account is added under Internet Accounts. Without that the item stays empty even while Outlook shows meetings, and nothing in the config is wrong.

Two flags are load-bearing. `icalBuddy` prints the title before the datetime by default, which made the original parser return nothing, so `-po "datetime,title"` forces the order. `-ps "|@|"` sets `@` as the separator, because titles contain almost every other punctuation character.

All-day events are dropped at the source with `-ea`, and the parser skips them again defensively. Holiday, birthday, reminder and task calendars are excluded by name through `-ec`, so a public holiday cannot masquerade as a meeting.

## top reports a lifetime average first

`top` reports a lifetime average in its first sample, so `cpu.sh` takes two and reads the second:

```bash
top -l 2 -n 0
```

The value shown is `100 - idle`. Summing `ps -o %cpu` was tried and drifts low, because those are per-process lifetime averages rather than a live interval.

## Memory pressure needs three page classes

A single `vm_stat` call supplies active, wired and compressed pages. Their sum times the page size is the used figure, which tracks what Activity Monitor calls memory used. Total physical memory comes from `sysctl -n hw.memsize`.

## Throughput needs a previous sample

`netstat -ibn` reports cumulative counters, not rates. `network.sh` diffs them against `/tmp/sketchybar_net_en0`, which also stores the timestamp of the previous run so the divisor is real elapsed time rather than the assumed interval.

The formatter pads output to four characters with `printf "%4s"`. Without the padding the label changes width as throughput moves between `300B` and `1.2M`, and every item to its left shifts. Remove the padding only if the font stops being monospaced.

## Private Use Area glyphs get stripped

Nerd Font glyphs sit in the Unicode Private Use Area, and several editors and tools drop those characters silently on write. A stripped glyph produces no error, leaves no visible diff, and renders the item blank.

Every glyph is therefore stored as a bash ANSI-C escape, which keeps `icons.sh` pure ASCII. See [Icon constants](../reference/icons.md) for the values and the verification command.

## Themes are scripts because SketchyBar has no palette

SketchyBar has no concept of a colour scheme, so a theme is a script that re-sets colours on the running bar. Three levers cover it: `--bar color`, a wildcard `--set '/.*/'` for the defaults every item inherits, and per-item overrides for anything special such as the `front_app` pill.

Colours use `0xAARRGGBB`, alpha first.

Items are never recreated, so a theme applies with no flicker and no loss of state.
