# sketchybar config

A Dracula-themed macOS status bar built on [SketchyBar](https://github.com/FelixKratz/SketchyBar), with app focus, calendar, media, and system stats.

Most items here have an unusual implementation because the obvious approach stopped working on modern macOS. The explanation section records which API Apple removed and what replaced it.

## Tutorials

Learn the setup from zero.

- [Install and run the bar](tutorials/10-install.md)

## How-to guides

Task recipes for someone already running the bar.

- [Add a bar item](how-to/add-an-item.md)
- [Switch themes](how-to/switch-themes.md)
- [Fix the mic and camera watcher](how-to/fix-the-mic-camera-watcher.md)

## Reference

Exact facts about items, files, and dependencies.

- [Bar items](reference/bar-items.md)
- [Runtime files and events](reference/runtime-files.md)
- [Dependencies and permissions](reference/dependencies.md)
- [Icon constants](reference/icons.md)

## Explanation

Why the code looks the way it does.

- [macOS constraints](explanation/macos-constraints.md)
- [How the now-playing item works](explanation/now-playing.md)
