# Dependencies and permissions

See also: [Install and run the bar](../tutorials/10-install.md) · [Bar items](bar-items.md)

## Packages

| Package | Needed by | Install |
| --- | --- | --- |
| `sketchybar` | everything | `brew install sketchybar` |
| `sf-symbols` | optional; not used by any current plugin | `brew install --cask sf-symbols` |
| `ical-buddy` | `next_meeting` | `brew install ical-buddy` |
| `nowplaying-cli` | `media` | `brew install nowplaying-cli` |
| JetBrains Mono Nerd Font | every glyph | `brew install --cask font-jetbrains-mono-nerd-font` |

`sketchybar` comes from the `FelixKratz/formulae` tap:

```bash
brew tap FelixKratz/formulae
```

A missing `nowplaying-cli` is reported on the bar itself. The `media` item draws the label `nowplaying-cli missing` rather than failing silently.

## macOS permissions

| Permission | Needed for | Granted in |
| --- | --- | --- |
| Automation (Apple Events) | volume control | prompted on first use |
| Accessibility | reading a browser window title for the `media` item | System Settings → Privacy & Security → Accessibility |

Automation is requested with a dialog the first time a script targets an application, which in practice means the first volume scroll. Reading playback data needs no permission at all, and the click handler uses `open -b` rather than Apple Events.

The `media` item degrades cleanly without Accessibility: MediaRemote players such as Spotify still show, and browser playback shows nothing.

## System requirements

| Requirement | Value |
| --- | --- |
| Architecture | Apple Silicon |
| Tested on | macOS Sonoma through Tahoe 26.6 |

The microphone and camera indicators depend on Control Center log output and have only been verified on Apple Silicon.
