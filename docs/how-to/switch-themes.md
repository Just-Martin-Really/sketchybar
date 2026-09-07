# Switch themes

See also: [macOS constraints](../explanation/macos-constraints.md#themes-are-scripts-because-sketchybar-has-no-palette) · [Add a bar item](add-an-item.md)

A theme is a script that recolours the running bar. Items are never recreated, so switching is instant and loses no state.

## Preview without committing

Run the theme script directly:

```bash
~/.config/sketchybar/themes/tokyonight.sh
```

The bar changes immediately. The next `sketchybar --reload` reverts to whatever `sketchybarrc` sources.

## Make a theme permanent

Change the `source` line at the end of `sketchybarrc`:

```bash
source "$CONFIG_DIR/themes/tokyonight.sh"
```

Then reload:

```bash
sketchybar --reload
```

## Write a new theme

Copy an existing theme and edit the colours. Four levers cover everything:

```bash
sketchybar --bar color=0xee282a36
sketchybar --set '/.*/' icon.color=0xffbd93f9 label.color=0xfff8f8f2
sketchybar --set front_app background.color=0x8844475a
```

Colours are `0xAARRGGBB`, alpha first.

The wildcard `--set '/.*/'` applies to every item that already exists, so it must run after the items are added. Sourcing the theme at the end of `sketchybarrc` guarantees that.

Alert colours for the mic and camera indicators are set inside `plugins/mic.sh` and `plugins/camera.sh` and are reapplied on every event, so a theme cannot override them. Edit those plugins to change them.
