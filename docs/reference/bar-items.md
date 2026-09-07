# Bar items

See also: [Add a bar item](../how-to/add-an-item.md) · [Runtime files and events](runtime-files.md) · [Dependencies and permissions](dependencies.md)

Every item declared in `sketchybarrc`, with its refresh source and click action.

## Left side

| Item | Refresh | Script | Click action |
| --- | --- | --- | --- |
| `front_app` | `front_app_switched` event | `front_app.sh` | none |
| `next_meeting` | 60s | `next_meeting.sh` | `next_meeting_join.sh` |
| `media` | 3s | `media.sh` | `media_click.sh` |

## Right side

Items are added rightmost first, so `clock` sits furthest right and `cpu` furthest left within this group.

| Item | Refresh | Script | Click action |
| --- | --- | --- | --- |
| `clock` | 10s | `clock.sh` | `open -a Calendar` |
| `camera` | `camera_change` event | `camera.sh` | none |
| `mic` | `mic_change` event | `mic.sh` | none |
| `volume` | `volume_change`, `mouse.scrolled` | `volume.sh` | Sound settings pane |
| `battery` | 60s, `system_woke`, `power_source_change` | `battery.sh` | Battery settings pane |
| `wifi` | 30s, `wifi_change` | `wifi.sh` | Wi-Fi settings pane |
| `network` | 2s | `network.sh` | none |
| `ram` | 5s | `ram.sh` | Activity Monitor |
| `cpu` | 5s | `cpu.sh` | Activity Monitor |

## Item behaviour

| Item | Output | Hidden when |
| --- | --- | --- |
| `front_app` | focused application name in a pill | never |
| `next_meeting` | `HH:MM Title`, red within 10 minutes of the start | never; reads `No more meetings today` when the day is clear |
| `media` | `Artist - Title`, or the window title for a browser | nothing is playing |
| `clock` | `DD/MM HH:MM` | never |
| `camera` | camera glyph in alert colour | camera not in use |
| `mic` | microphone glyph in alert colour | microphone not in use |
| `volume` | `NN%` with a level-dependent glyph | never |
| `battery` | `NN%` with a level-dependent glyph | never |
| `wifi` | `-NNdBm` | never; label empties when the interface is down |
| `network` | `↑ NNNN ↓ NNNN`, padded to four characters | never |
| `ram` | `USED/TOTALG` | never |
| `cpu` | `NN%` | never |

The `media` item sets `label.max_chars=28` with `scroll_texts=on`, so longer titles scroll rather than truncate.

## Bar appearance

| Property | Value |
| --- | --- |
| `position` | `top` |
| `height` | `36` |
| `blur_radius` | `30` |
| `padding_left` | `8` |
| `padding_right` | `20` |
| `corner_radius` | `0` |

`padding_right` must stay at roughly 20 or more. The macOS privacy indicator sits in the top-right corner and overlaps the rightmost item below that.

## Item defaults

| Property | Value |
| --- | --- |
| `icon.font` | `JetBrainsMono Nerd Font:Bold:15.0` |
| `label.font` | `JetBrainsMono Nerd Font:Semibold:13.0` |
| `background.height` | `22` |
| `background.corner_radius` | `6` |

Colours are not listed here. `sketchybarrc` sets defaults, and the theme sourced at the end of the file overrides them.
