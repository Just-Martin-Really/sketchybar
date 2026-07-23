# sketchybar

My personal [SketchyBar](https://github.com/FelixKratz/SketchyBar) configuration for macOS. A custom top bar with app focus, calendar, media, and system stats, themed with Dracula.

## Layout

**Left**
- Focused-app pill
- Next calendar meeting today (click to join the Teams call)
- Now playing (Spotify / Apple Music), scrolling title

**Right** (rightmost first)
- Clock (click opens Calendar)
- Battery
- Volume (scroll to change)
- Wi-Fi state
- Network throughput (up/down)
- RAM
- CPU
- Mic / camera in-use indicators

## Requirements

- macOS (Apple Silicon; developed on Sonoma/Tahoe)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
- [JetBrains Mono Nerd Font](https://www.nerdfonts.com/) for the glyphs
- [`icalBuddy`](https://github.com/ali-rantakari/icalBuddy) for the next-meeting item

```sh
brew tap FelixKratz/formulae
brew install sketchybar ical-buddy
brew install --cask font-jetbrains-mono-nerd-font sf-symbols
```

## Install

Clone into the SketchyBar config location and start the service:

```sh
git clone git@github.com:Just-Martin-Really/sketchybar.git ~/.config/sketchybar
brew services start sketchybar
```

Apply config changes without a full restart:

```sh
sketchybar --reload
```

## File layout

```
.
├── sketchybarrc        # main config, sourced on every reload
├── icons.sh            # Nerd Font glyph constants (bash ANSI-C escapes)
├── plugins/            # per-item scripts, invoked with $NAME / $SENDER / $INFO
│   ├── avwatch.sh          # background log-stream daemon for mic/cam indicators
│   ├── battery.sh
│   ├── camera.sh
│   ├── clock.sh
│   ├── cpu.sh
│   ├── front_app.sh
│   ├── media.sh            # polls Spotify + Apple Music via osascript
│   ├── media_click.sh
│   ├── mic.sh
│   ├── network.sh          # throughput, diffs netstat against a /tmp state file
│   ├── next_meeting.sh     # next timed event today via icalBuddy
│   ├── next_meeting_join.sh# opens the Teams join link of the current/next event
│   ├── ram.sh
│   ├── volume.sh           # click opens Sound settings, scroll changes volume
│   └── wifi.sh
└── themes/
    ├── dracula.sh      # active theme
    └── tokyonight.sh   # alternate
```

## Themes

Each theme is a standalone script that recolors the bar live (no items are recreated). The active theme is `source`d at the end of `sketchybarrc`, so it survives reloads. To switch, change the `source` line and run `sketchybar --reload`; to preview, just run the theme script directly.

## Notes

- **Glyphs** live in `icons.sh` as `$'\uXXXX'` escapes and are sourced where needed, rather than embedding literal Private Use Area characters in scripts.
- **Mic / camera indicators** can't be reliably polled on Apple Silicon, so `avwatch.sh` runs a long-lived `log stream` on Control Center's privacy-indicator subsystem, writes state to `/tmp`, and triggers `mic_change` / `camera_change` events.
- **Media** uses `osascript` polling instead of the deprecated `media_change` event. The first poll triggers a one-time Apple Events permission prompt.
- **Next meeting** reads the macOS Calendar via `icalBuddy` (Outlook/M365 works once the Exchange account is added to macOS Internet Accounts). All-day and holiday/birthday/reminder calendars are excluded.
- **Wi-Fi** shows connection state only; macOS 14+ redacts the SSID without Location Services, and the `airport` CLI was removed.
