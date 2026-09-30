# Why the bar resizes itself

See also: [Bar items](../reference/bar-items.md) · [Dependencies and permissions](../reference/dependencies.md)

SketchyBar sizes everything in points. A point is a logical unit, not a physical one, so the same number covers a different amount of glass on displays of different pixel density.

Two displays on one desk show how wide the gap gets.

| Display | Logical size | Backing scale | Diagonal | Points per inch |
| --- | --- | --- | --- | --- |
| 1080p monitor | 1920x1080 | 1x | 23.4" | 94 |
| Retina laptop panel | 1710x1112 | 2x | 13.6" | 150 |

A `height=36` bar is 6.1mm tall on the laptop and 9.7mm on the monitor, 59% larger, and the fonts grow by the same factor. On a 1x panel there is also no downsampling, so the glyphs look heavier as well as bigger.

Nothing is misconfigured when this happens. One set of point sizes is meeting two densities.

## What the bar does about it

`plugins/bar_scale.sh` runs on `display_change` and rescales the bar height, both fonts and the pill height from the combined density of the connected displays.

The scale is not the plain density ratio, because the eye measures angles rather than millimetres and a monitor sits further away than a laptop screen.

At roughly 50cm and 70cm, a 36 point bar covers 12.2 milliradians of the visual field on the 150 ppi laptop and 13.9 on the 94 ppi monitor. Physically it is 1.59 times larger; to the viewer it is 1.13 times larger. Correcting the full 1.59 would take the monitor to 0.72x the laptop and read as too small.

So the ratio is raised to a power below 1. Against that pair an exponent of 0.3 gives angular parity and the shipped 0.4 lands just under it. This is the one value worth adjusting by eye, and it lives in `sizes.sh`.

Every value involved lives in `sizes.sh`, which both `sketchybarrc` and the plugin source, so the startup layout and the rescaled one cannot drift apart.

## One height, several displays

SketchyBar has a single global bar height. It draws on every display at the same size, so with two displays of different density there is no setting that is right for both. The only choice is where to put the error.

Measured on a 149.5 ppi laptop beside a 94.2 ppi monitor, with the shipped exponent:

| Sized for | Laptop | Monitor | Bar moves? |
| --- | --- | --- | --- |
| nothing, one fixed size | correct | 20% too large | no |
| the focused display | correct | correct | yes, on every crossing |
| the main display | 17% too small | correct | no |
| combined density | 8% too small | 10% too large | no |

Following focus is the tempting reading of `display_change`, and it is the worst of these in practice. Both bars are on screen at once, so the bar being looked at visibly jumps every time focus crosses between displays.

Sizing for one display parks the entire error on the other. The combined density splits it instead, which is why the helper returns the geometric mean rather than any one display's value. A geometric mean is the right average here because the bar scales by this number multiplicatively, and with a single display connected it reduces to that display.

## Why a compiled helper

Density cannot be derived from anything SketchyBar reports. Its display query gives an arrangement id, a display id, a UUID and a point-space frame, but never a physical size, and physical size is exactly what a density needs. So `helpers/display_ppi.swift` is compiled on first run and asks `CGDisplayScreenSize`.

It pulls in no UI framework. The same measurement through `NSScreen` takes about 42ms per call against 12ms, because AppKit has to load.

That choice has a cost, and it is the sleeping-display case below: CoreGraphics reports no physical size while the screens are off, where `NSScreen` still answers correctly. The 30ms is worth more than the edge case, because `system_woke` already covers it.

Without `swiftc` the helper is never built and the bar keeps the sizes `sketchybarrc` set, which is exactly how it behaved before any of this existed.

## Sleeping displays

macOS reports no active displays while the screens are asleep, and `sketchybar --query displays` returns an empty array in that state. A reload with the screens off therefore leaves the shipped sizes in place.

That is why the item subscribes to `system_woke` as well as `display_change`. Without it a bar reloaded before the displays came back would stay at the wrong size until the next time the active display changed.

One case is still not covered. A display waking on its own, from a mouse movement rather than from the system waking, fires neither event. A reload that happened while that display slept keeps the shipped sizes until the next display switch. This is narrow enough to leave alone: reloads happen when the config is edited, and the screen is awake at that point.
