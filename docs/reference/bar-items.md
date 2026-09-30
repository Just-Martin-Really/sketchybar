# Bar items

See also: [Add a bar item](../how-to/add-an-item.md) · [Runtime files and events](runtime-files.md) · [Dependencies and permissions](dependencies.md)

Every item declared in `sketchybarrc`, with its refresh source and click action.

## Left side

| Item | Refresh | Script | Click action |
| --- | --- | --- | --- |
| `front_app` | `front_app_switched` event | `front_app.sh` | none |
| `next_meeting` | 60s | `next_meeting.sh` | `next_meeting_join.sh` |
| `media` | 3s | `media.sh` | `media_click.sh` |
| `display_scale` | `display_change`, `system_woke` | `bar_scale.sh` | none |

`display_scale` draws nothing. It exists only to hold the subscription that resizes the bar for the connected displays, explained in [Why the bar resizes itself](../explanation/display-density.md). `sketchybarrc` also runs `bar_scale.sh` once directly at the end of a reload, so the first sizing does not wait for a display switch.

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
| `height` | `36` at 150 ppi, scaled per display |
| `blur_radius` | `30` |
| `padding_left` | `8` |
| `padding_right` | `20` |
| `corner_radius` | `0` |

`padding_right` must stay at roughly 20 or more. The macOS privacy indicator sits in the top-right corner and overlaps the rightmost item below that.

## Item defaults

| Property | Value |
| --- | --- |
| `icon.font` | `JetBrainsMono Nerd Font:Bold:15.0` at 150 ppi, scaled per display |
| `label.font` | `JetBrainsMono Nerd Font:Semibold:13.0` at 150 ppi, scaled per display |
| `background.height` | `22` at 150 ppi, scaled per display |
| `background.corner_radius` | `6` |

The four scaled values are the base sizes in `sizes.sh`, which apply unchanged on a 150 points-per-inch display. `bar_scale.sh` rewrites them for the active display, so a running bar reports different numbers. See [Why the bar resizes itself](../explanation/display-density.md).

Colours are not listed here. `sketchybarrc` sets defaults, and the theme sourced at the end of the file overrides them.

## Theme colour contract

Every theme defines these, and plugins read them instead of hardcoding hex. Values are `0xAARRGGBB`, alpha first.

| Variable | Used by |
| --- | --- |
| `COLOR_BAR` | bar background |
| `COLOR_ICON` | default item icon |
| `COLOR_LABEL` | default item label |
| `COLOR_PILL`, `COLOR_PILL_TEXT` | the `front_app` pill |
| `COLOR_ACCENT` | `next_meeting`, upcoming |
| `COLOR_URGENT` | `next_meeting`, within ten minutes |
| `COLOR_MUTED` | `next_meeting`, nothing left today |
| `COLOR_ALERT` | `mic` and `camera` while in use |
