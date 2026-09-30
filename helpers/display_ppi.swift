// Combined points-per-inch across every active display.
//
// Used by plugins/bar_scale.sh to size the bar. SketchyBar has one global bar
// height, so no single display's density is the right answer when several are
// connected: sizing for one leaves the others wrong by the full ratio between
// them. The geometric mean splits that error instead of parking all of it on
// one screen, and it is the correct average for a quantity the bar scales by
// multiplicatively.
//
// With one display connected the mean is that display, which is the whole point.
//
// CoreGraphics only rather than NSScreen, which costs about 42ms per call
// against 12ms. The trade-off runs the other way while displays sleep:
// CGDisplayScreenSize reports nothing then and this exits 1, where NSScreen
// would still answer. plugins/bar_scale.sh covers that with system_woke.
import CoreGraphics
import Foundation

var ids = [CGDirectDisplayID](repeating: 0, count: 16)
var count: UInt32 = 0
guard CGGetActiveDisplayList(16, &ids, &count) == .success, count > 0 else { exit(1) }

var logSum = 0.0
var measured = 0

for id in ids[0..<Int(count)] {
    let millimetres = CGDisplayScreenSize(id)
    let bounds = CGDisplayBounds(id)
    // Sleeping displays, and some virtual and capture devices, report no
    // physical size. Skip them rather than letting one poison the mean.
    guard millimetres.width > 0, millimetres.height > 0, bounds.width > 0 else { continue }

    let diagonalInches = (millimetres.width * millimetres.width
                        + millimetres.height * millimetres.height).squareRoot() / 25.4
    let diagonalPoints = (bounds.width * bounds.width
                        + bounds.height * bounds.height).squareRoot()
    logSum += log(diagonalPoints / diagonalInches)
    measured += 1
}

guard measured > 0 else { exit(1) }
print(Int(exp(logSum / Double(measured)).rounded()))
