# Fix the mic and camera watcher

See also: [macOS constraints](../explanation/macos-constraints.md#microphone-and-camera-cannot-be-polled) · [Runtime files and events](../reference/runtime-files.md)

The mic and camera indicators stop updating when more than one watcher runs, or when none does. Both show the same symptom: an indicator stuck on or stuck off.

## Count the log streams, not the bash processes

A healthy single watcher shows **two** `bash avwatch.sh` processes. The second is the subshell bash forks for the `log stream | while read` pipeline, not a duplicate. Counting bash processes will mislead you.

Count the stream children instead:

```bash
pgrep -f 'log stream.*controlcenter' | wc -l
```

Exactly `1` is correct.

- `1` means the watcher is healthy. If an indicator is still wrong, check the state files below.
- `0` means no watcher is running. Reload the bar.
- `2` or more means a watcher outlived its parent and the startup cleanup in `avwatch.sh` did not match it. Clean it up by hand.

## Clean up orphaned watchers

```bash
pkill -f avwatch.sh
pkill -f 'log stream.*controlcenter'
sketchybar --reload
```

Then recount. The result must be `1`.

## Inspect the state directly

The watcher writes `0` or `1` to two files, which the plugins read verbatim:

```bash
cat /tmp/sb_mic_state /tmp/sb_camera_state
```

If a file says `1` while nothing is using the sensor, no event arrived to clear it. Reload the bar to reset both to `0`.

## Confirm the log stream produces events

Run the same predicate the watcher uses, then start or stop a call:

```bash
log stream --style compact \
  --predicate 'subsystem == "com.apple.controlcenter" AND category == "sensor-indicators"'
```

Lines beginning `Sorted active attributions from SystemStatus update:` carry `[cam]`, `[mic]` and `[scr]` markers. No lines on a sensor change means macOS changed the subsystem or category, and the predicate in `plugins/avwatch.sh` needs updating along with the `pkill` patterns at the top of that file.

!!! warning

    An application that holds screen recording permanently, such as AltTab, keeps `[scr]` active and the macOS privacy dot lit. That is not this config, and no amount of watcher surgery will clear it.
