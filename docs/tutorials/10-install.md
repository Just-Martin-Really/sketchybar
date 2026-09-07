# Install and run the bar

See also: [Dependencies and permissions](../reference/dependencies.md) · [Add a bar item](../how-to/add-an-item.md)

Get this configuration running on a fresh Apple Silicon Mac.

## Prerequisites

- macOS on Apple Silicon
- [Homebrew](https://brew.sh)

## 1. Install the packages

```bash
brew tap FelixKratz/formulae
brew install sketchybar ical-buddy nowplaying-cli
brew install --cask font-jetbrains-mono-nerd-font sf-symbols
```

## 2. Clone the configuration

SketchyBar reads `~/.config/sketchybar`, so clone directly into it:

```bash
git clone git@github.com:Just-Martin-Really/sketchybar.git ~/.config/sketchybar
```

## 3. Start the service

```bash
brew services start sketchybar
```

The bar appears at the top of the screen within a second or two.

## 4. Hide the native menu bar

The macOS menu bar cannot be moved or placed behind SketchyBar. Set System Settings → Control Center → Menu Bar → Automatically hide and show → Always.

The native bar still slides over SketchyBar when the pointer reaches the top edge. That behaviour cannot be disabled.

## 5. Grant the permissions

Two items need permission before they work.

For browser playback, add SketchyBar under System Settings → Privacy & Security → Accessibility. Without it, browser tracks never appear and the item stays empty while a browser is playing.

Scrolling the volume item prompts for Automation access the first time. Accept it. Nothing else in the bar needs a permission: playback data comes from MediaRemote, which requires none.

## 6. Verify

Query an item directly rather than squinting at the bar:

```bash
sketchybar --query cpu
```

The output includes the current label, so a value like `19%` confirms the plugin runs.

## What you have now

A running bar with the focused app, next meeting, and now playing on the left, and system stats on the right.

Apply any later change with `sketchybar --reload`. Avoid `brew services restart`, which can orphan the background watcher that drives the microphone and camera indicators.

Next: [Add a bar item](../how-to/add-an-item.md) or [Switch themes](../how-to/switch-themes.md).
