# Icon constants

See also: [macOS constraints](../explanation/macos-constraints.md#private-use-area-glyphs-get-stripped) · [Add a bar item](../how-to/add-an-item.md)

Nerd Font glyphs live in the Unicode Private Use Area. Several editors and tools strip those characters silently on write, producing no error and no visible diff, so `icons.sh` stores them as bash ANSI-C escapes and stays pure ASCII.

## Constants in icons.sh

| Constant | Codepoint | Definition | Used by |
| --- | --- | --- | --- |
| `ICON_MUSIC` | `U+F001` | `$'\uf001'` | `media` |
| `ICON_CLOCK` | `U+F017` | `$'\uf017'` | `clock` |
| `ICON_RAM` | `U+F2DB` | `$'\uf2db'` | `ram` |
| `ICON_CPU` | `U+F4BC` | `$'\uf4bc'` | `cpu` |
| `ICON_NET` | `U+F0AC` | `$'\uf0ac'` | `network` |
| `ICON_CAM` | `U+F030` | `$'\uf030'` | `camera.sh` |
| `ICON_MIC` | `U+F130` | `$'\uf130'` | `mic.sh` |
| `ICON_CAL` | `U+F073` | `$'\uf073'` | `next_meeting.sh` |

Bash expands the escape at runtime. Source the file rather than pasting a glyph:

```bash
source "$HOME/.config/sketchybar/icons.sh"
sketchybar --set "$NAME" icon="$ICON_CPU"
```

## Glyphs still embedded in plugins

Three plugins pick a glyph from a range of values and keep them inline rather than defining a constant per level.

| Plugin | Glyphs | Range | Risk |
| --- | --- | --- | --- |
| `battery.sh` | 6 | `U+F0E7`, `U+F240`–`U+F244` | 3-byte UTF-8 in the Private Use Area, so it can be stripped |
| `volume.sh` | 4 | `U+F057E`–`U+F0581` | 4-byte UTF-8 outside the PUA, survives tooling |
| `wifi.sh` | 2 | `U+F05A9`, `U+F05AA` | 4-byte UTF-8 outside the PUA, survives tooling |

The `volume.sh` and `wifi.sh` glyphs are Material Design Icons in the supplementary planes. Their 4-byte encoding is not affected by the stripping that hits 3-byte PUA characters, so they are left alone.

The `battery.sh` glyphs are Font Awesome and do sit in the vulnerable range. They shipped with the SketchyBar formula and have survived every edit so far, so they are left as they are rather than rewritten for consistency.

## Verify what is in a file

Reading the bytes is the only reliable check, because a stripped glyph is invisible in an editor:

```bash
hexdump -C icons.sh | head
```

`icons.sh` must contain no byte above `0x7f`. Confirm with:

```bash
python3 -c "print(all(b < 128 for b in open('icons.sh','rb').read()))"
```
