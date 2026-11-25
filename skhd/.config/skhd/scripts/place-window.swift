// place-window: size and center one window of an app, then bring it to front.
//
//   place-window "<App Name>" "<title substring>" [<width> <height>]
//
// Waits up to 3 s for a window whose title contains <title substring> to appear (so callers
// don't need a fixed `sleep`), then centers it horizontally and puts it in the upper third of
// the primary screen. Without <width> <height> the window is only brought to front, not moved.
// Searches every running instance of the app (`open -n` spawns new ones).
//
// Build (binary goes to ~/.local/bin): `mise run skhd-build`, or by hand:
//   swiftc -O -swift-version 5 -o ~/.local/bin/place-window ~/.config/skhd/scripts/place-window.swift
//
// Needs Accessibility permission; when launched from skhd it inherits skhd's.

import AppKit
import ApplicationServices

let args = CommandLine.arguments
let usage = "usage: place-window \"<App Name>\" \"<title substring>\" [<width> <height>]\n"
guard args.count == 3 || args.count == 5 else {
    FileHandle.standardError.write(Data(usage.utf8))
    exit(2)
}
let size: CGSize? = args.count == 5 ? Double(args[3]).flatMap { w in Double(args[4]).map { CGSize(width: w, height: $0) } } : nil
if args.count == 5 && size == nil {
    FileHandle.standardError.write(Data(usage.utf8))
    exit(2)
}
let (name, titlePart) = (args[1], args[2])

guard AXIsProcessTrusted() else {
    FileHandle.standardError.write(Data("place-window: Accessibility permission missing\n".utf8))
    exit(1)
}

func attr<T>(_ el: AXUIElement, _ key: String) -> T? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(el, key as CFString, &value) == .success else { return nil }
    return value as? T
}

func findWindow() -> (app: NSRunningApplication, window: AXUIElement)? {
    for app in NSWorkspace.shared.runningApplications where app.activationPolicy == .regular {
        let names = [app.localizedName, app.bundleURL?.deletingPathExtension().lastPathComponent]
        guard names.contains(where: { $0?.caseInsensitiveCompare(name) == .orderedSame }) else { continue }
        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        for window in attr(axApp, kAXWindowsAttribute) as [AXUIElement]? ?? [] {
            if (attr(window, kAXTitleAttribute) as String?)?.contains(titlePart) == true {
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
    FileHandle.standardError.write(Data("place-window: no \"\(titlePart)\" window in \(name)\n".utf8))
    exit(1)
}

if var size {
    let screen = NSScreen.screens[0].frame  // primary screen; AX uses a top-left origin
    var origin = CGPoint(x: (screen.width - size.width) / 2, y: (screen.height - size.height) / 3)
    if let v = AXValueCreate(.cgSize, &size) { AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, v) }
    if let v = AXValueCreate(.cgPoint, &origin) { AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, v) }
}

app.unhide()
AXUIElementPerformAction(window, kAXRaiseAction as CFString)
AXUIElementSetAttributeValue(AXUIElementCreateApplication(app.processIdentifier), kAXFrontmostAttribute as CFString, kCFBooleanTrue)
