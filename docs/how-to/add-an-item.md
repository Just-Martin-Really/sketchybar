# Add a bar item

See also: [Bar items](../reference/bar-items.md) · [Icon constants](../reference/icons.md) · [Switch themes](switch-themes.md)

## Write the plugin

Create the script under `plugins/`. SketchyBar passes `$NAME` for the item name, plus `$SENDER` and `$INFO` for event-driven items.

```bash
#!/usr/bin/env bash
source "$HOME/.config/sketchybar/icons.sh"

sketchybar --set "$NAME" label="$(some_command)"
```

Make it executable:

```bash
chmod +x ~/.config/sketchybar/plugins/myitem.sh
```

!!! warning

    Do not paste a Nerd Font glyph into the script. Those characters live in the Private Use Area and several tools strip them silently. Add a constant to `icons.sh` instead and source it. See [Icon constants](../reference/icons.md).

## Register the item

Add it to `sketchybarrc`:

```bash
sketchybar --add item myitem right \
           --set myitem update_freq=10 icon="$ICON_FOO" \
                  script="$PLUGIN_DIR/myitem.sh"
```

On the right side items are added rightmost first, so the first `--add ... right` lands furthest right.

## Prefer events over polling

If the value only changes on a system event, subscribe instead of setting `update_freq`:

```bash
sketchybar --add item myitem right \
           --set myitem script="$PLUGIN_DIR/myitem.sh" \
           --subscribe myitem volume_change
```

For a custom event, declare it once near the top of `sketchybarrc`:

```bash
sketchybar --add event my_event
```

Then fire it from anywhere:

```bash
sketchybar --trigger my_event
```

## Apply and verify

```bash
sketchybar --reload
sketchybar --query myitem
```

`--query` prints the item's current icon, label and drawing state, which is the fastest way to tell a broken script from a hidden item.
