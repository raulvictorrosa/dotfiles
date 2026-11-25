// cycle-app: focus-or-cycle helper for skhd hotkeys.
//
//   cycle-app "<App Name>"
//
//   app not running        -> open it
//   running, not in front  -> bring it to front
//   in front, >1 windows   -> raise the next window (rotates through all of them)
//   in front, 1 window     -> hide the app (like Cmd+H); the next press brings it back
//   in front, 0 windows    -> open it again (reopens a window)
//
// Build (binary is git-ignored, rebuild after editing):
//   swiftc -O -swift-version 5 -o ~/.config/skhd/scripts/cycle-app ~/.config/skhd/scripts/cycle-app.swift
//
// Needs Accessibility permission; when launched from skhd it inherits skhd's.

import AppKit
import ApplicationServices

guard CommandLine.arguments.count == 2 else {
    FileHandle.standardError.write(Data("usage: cycle-app \"<App Name>\"\n".utf8))
    exit(2)
}
let name = CommandLine.arguments[1]

func openApp() -> Never {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    p.arguments = ["-a", name]
    try? p.run()
    p.waitUntilExit()
    exit(p.terminationStatus)
}

// Match (case-insensitively, like `open -a`) on the displayed name or on the .app bundle name
// ("Code" is displayed for the "Visual Studio Code" app).
let app = NSWorkspace.shared.runningApplications.first { app in
    app.activationPolicy == .regular
        && [app.localizedName, app.bundleURL?.deletingPathExtension().lastPathComponent]
            .contains { $0?.caseInsensitiveCompare(name) == .orderedSame }
}
guard let app else { openApp() }

guard AXIsProcessTrusted() else {
    FileHandle.standardError.write(Data("cycle-app: Accessibility permission missing\n".utf8))
    app.activate()
    exit(1)
}

let axApp = AXUIElementCreateApplication(app.processIdentifier)

func attr<T>(_ el: AXUIElement, _ key: String) -> T? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(el, key as CFString, &value) == .success else { return nil }
    return value as? T
}

if NSWorkspace.shared.frontmostApplication?.processIdentifier != app.processIdentifier {
    // Same mechanism as System Events' `set frontmost`; unlike NSRunningApplication.activate()
    // it is not subject to macOS 14+ cooperative-activation limits.
    // Unhide first: a hidden app ignores the frontmost request.
    if app.isHidden {
        app.unhide()
        usleep(60_000)
    }
    AXUIElementSetAttributeValue(axApp, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
    exit(0)
}

// Windows come back front-to-back.
let windows = (attr(axApp, kAXWindowsAttribute) as [AXUIElement]? ?? []).filter {
    (attr($0, kAXSubroleAttribute) as String?) == kAXStandardWindowSubrole
        && (attr($0, kAXMinimizedAttribute) as Bool?) != true
}

switch windows.count {
case 0: openApp()
case 1: app.hide()
// Raising the back-most window rotates the whole stack.
default: AXUIElementPerformAction(windows[windows.count - 1], kAXRaiseAction as CFString)
}
