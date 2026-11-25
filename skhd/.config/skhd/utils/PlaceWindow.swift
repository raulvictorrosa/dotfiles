// skhd-utils place-window "<App Name>" "<title substring>" [<width> <height>]:
// size and center one window of an app, then bring it to front.
//
// Waits up to 3 s for a window whose title contains <title substring> to appear (so callers
// don't need a fixed `sleep`), then centers it horizontally and puts it in the upper third of
// the primary screen. Without <width> <height> the window is only brought to front, not moved.
// Searches every running instance of the app (`open -n` spawns new ones).

import AppKit
import ApplicationServices

/// `args` is [app, title] or [app, title, width, height].
func placeWindow(_ args: [String]) -> Never {
    var size: CGSize?
    if args.count == 4 {
        guard let w = Double(args[2]), let h = Double(args[3]) else {
            printError("place-window: width and height must be numbers")
            exit(2)
        }
        size = CGSize(width: w, height: h)
    }
    let (name, titlePart) = (args[0], args[1])

    guard AXIsProcessTrusted() else {
        printError("place-window: Accessibility permission missing")
        exit(1)
    }

    func findWindow() -> (app: NSRunningApplication, window: AXUIElement)? {
        for app in runningInstances(of: name) {
            for window in axAttribute(axElement(of: app), kAXWindowsAttribute) as [AXUIElement]? ?? [] {
                if (axAttribute(window, kAXTitleAttribute) as String?)?.contains(titlePart) == true {
                    return (app, window)
                }
            }
        }
        return nil
    }

    let deadline = Date().addingTimeInterval(3)
    var found = findWindow()
    while found == nil && Date() < deadline {
        usleep(50_000)
        found = findWindow()
    }
    guard let (app, window) = found else {
        printError("place-window: no \"\(titlePart)\" window in \(name)")
        exit(1)
    }

    if var size {
        let screen = NSScreen.screens[0].frame  // primary screen; AX uses a top-left origin
        var origin = CGPoint(x: (screen.width - size.width) / 2, y: (screen.height - size.height) / 3)
        if let v = AXValueCreate(.cgSize, &size) { AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, v) }
        if let v = AXValueCreate(.cgPoint, &origin) { AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, v) }
    }

    bringToFront(app, raising: window)
    exit(0)
}
