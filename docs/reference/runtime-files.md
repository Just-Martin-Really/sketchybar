# Runtime files and events

See also: [Fix the mic and camera watcher](../how-to/fix-the-mic-camera-watcher.md) · [Bar items](bar-items.md)

State written at runtime. None of it is version controlled, and all of it is safe to delete while the bar is stopped.

## State files

| Path | Format | Written by | Read by |
| --- | --- | --- | --- |
| `/tmp/sb_mic_state` | `0` or `1` | `avwatch.sh` | `mic.sh` |
| `/tmp/sb_camera_state` | `0` or `1` | `avwatch.sh` | `camera.sh` |
| `/tmp/sketchybar_avwatch.pid` | watcher PID | `avwatch.sh` | nothing; diagnostic only |
| `/tmp/sketchybar_net_en0` | `timestamp in_bytes out_bytes` | `network.sh` | `network.sh` |
| `$TMPDIR/sb_media_last` | `bundle_id<TAB>label` | `media.sh` | `media.sh` |

The media cache uses `$TMPDIR` rather than `/tmp` because it stores a string controlled by a web page. `$TMPDIR` is per-user and mode 700; `/tmp` is mode 1777.

Entries in the media cache expire after one minute and are reused only when the recorded bundle identifier matches the player that currently owns playback.

## Custom events

Declared in `sketchybarrc` and fired by `avwatch.sh`.

| Event | Fired when |
| --- | --- |
| `mic_change` | microphone in-use state changes |
| `camera_change` | camera in-use state changes |

## Built-in events used

| Event | Subscribed by |
| --- | --- |
| `front_app_switched` | `front_app` |
| `volume_change` | `volume` |
| `mouse.scrolled` | `volume` |
| `system_woke` | `battery` |
| `power_source_change` | `battery` |
| `wifi_change` | `wifi` |
