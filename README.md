# sketchybar

My personal [SketchyBar](https://github.com/FelixKratz/SketchyBar) configuration for macOS. A custom top bar with app focus, calendar, media, and system stats, themed with Dracula.

![sketchybar screenshot](assets/screenshot.png)

## Layout

**Left**
- Focused-app pill
- Next calendar meeting today (click to join the Teams call)
- Now playing, scrolling title

**Right** (rightmost first)
- Clock (click opens Calendar)
- Battery
- Volume (scroll to change)
- Wi-Fi signal in dBm
- Network throughput (up/down)
- RAM
- CPU
- Mic / camera in-use indicators

## Requirements

- macOS on Apple Silicon (developed on Sonoma through Tahoe 26)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
- [JetBrains Mono Nerd Font](https://www.nerdfonts.com/) for the glyphs
- [`icalBuddy`](https://github.com/ali-rantakari/icalBuddy) for the next-meeting item
- [`nowplaying-cli`](https://github.com/kirtan-shah/nowplaying-cli) for the now-playing item

```sh
brew tap FelixKratz/formulae
brew install sketchybar ical-buddy nowplaying-cli
brew install --cask font-jetbrains-mono-nerd-font sf-symbols
```

The now-playing item also needs Accessibility permission when the player is a browser. See [docs/design-notes.md](docs/design-notes.md#now-playing).

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

Use `--reload` rather than `brew services restart`. A restart kills the parent process and can orphan the `log stream` child that `avwatch.sh` depends on.

## File layout

```
.
├── sketchybarrc        # main config, sourced on every reload
├── icons.sh            # Nerd Font glyph constants (bash ANSI-C escapes)
├── docs/
│   └── design-notes.md # why each item works the way it does
├── plugins/            # per-item scripts, invoked with $NAME / $SENDER / $INFO
│   ├── avwatch.sh          # background log-stream daemon for mic/cam indicators
│   ├── battery.sh
│   ├── camera.sh
│   ├── clock.sh
│   ├── cpu.sh
│   ├── front_app.sh
│   ├── media.sh            # track name via MediaRemote, with a browser fallback
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

Each theme is a standalone script that recolors the bar live. No items are recreated; only `bar color`, the `--set '/.*/'` defaults, and a few per-item overrides change. The active theme is `source`d at the end of `sketchybarrc`, so it survives reloads.

To switch, change the `source` line and run `sketchybar --reload`. To preview without committing, run the theme script directly. The next reload reverts it.

## Notes

Most items here exist in an unusual shape because the obvious approach does not work on modern macOS. [docs/design-notes.md](docs/design-notes.md) explains each one. The short version:

- **Glyphs** live in `icons.sh` as `$'\uXXXX'` escapes. Editors and tooling silently strip raw Private Use Area characters, so the escapes keep the bytes in one place.
- **Now playing** reads macOS MediaRemote through `nowplaying-cli`. Firefox publishes no track metadata, so its title comes from the window title instead.
- **Mic / camera indicators** cannot be polled on Apple Silicon. `avwatch.sh` streams Control Center's privacy-indicator log and triggers `mic_change` / `camera_change`.
- **Next meeting** reads macOS Calendar via `icalBuddy`. Outlook and M365 events appear once the Exchange account is added to Internet Accounts.
- **Wi-Fi** reports RSSI from `system_profiler`. The `airport` binary was removed in macOS 14.4, and `wdutil` requires sudo.
