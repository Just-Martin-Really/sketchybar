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

Copy an existing theme and edit the colours. Three levers cover everything:

```bash
sketchybar --bar color=0xee282a36
sketchybar --set '/.*/' icon.color=0xffbd93f9 label.color=0xfff8f8f2
sketchybar --set front_app background.color=0x8844475a
```

Colours are `0xAARRGGBB`, alpha first.

The wildcard `--set '/.*/'` applies to every item that already exists, so it must run after the items are added. Sourcing the theme at the end of `sketchybarrc` guarantees that.

Plugins that need a colour read it from the theme rather than inlining hex, so a theme reaches every item. `mic.sh` and `camera.sh` use `COLOR_ALERT`; `next_meeting.sh` uses `COLOR_MUTED`, `COLOR_ACCENT` or `COLOR_URGENT` depending on how close the meeting is.

## Keep a palette off the repo

`themes/active.sh` sources `themes/local.sh` when it exists, and the shipped default otherwise. `local.sh` is gitignored, so a personal palette runs on the machine without being committed.

```bash
cp themes/dracula.sh themes/local.sh
```

Edit the copy, then reload. To go back to the shipped theme, move it aside:

```bash
mv themes/local.sh themes/local.sh.off
sketchybar --reload
```
