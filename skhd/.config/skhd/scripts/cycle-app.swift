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
// All running instances of the app count as one (`open -n -a Ghostty` starts a separate process
// per btop/cliamp/nvim window). Windows are ordered with the system-wide front-to-back list.
//
// Build (binary goes to ~/.local/bin): `mise run skhd-build`, or by hand:
//   swiftc -O -swift-version 5 -o ~/.local/bin/cycle-app ~/.config/skhd/scripts/cycle-app.swift
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
let instances = NSWorkspace.shared.runningApplications.filter { app in
    app.activationPolicy == .regular
        && [app.localizedName, app.bundleURL?.deletingPathExtension().lastPathComponent]
            .contains { $0?.caseInsensitiveCompare(name) == .orderedSame }
}
if instances.isEmpty { openApp() }

guard AXIsProcessTrusted() else {
    FileHandle.standardError.write(Data("cycle-app: Accessibility permission missing\n".utf8))
    instances[0].activate()
    exit(1)
}

func attr<T>(_ el: AXUIElement, _ key: String) -> T? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(el, key as CFString, &value) == .success else { return nil }
    return value as? T
}

func frame(of window: AXUIElement) -> CGRect? {
    var origin = CGPoint.zero, size = CGSize.zero
    guard let p = attr(window, kAXPositionAttribute) as AXValue?, let s = attr(window, kAXSizeAttribute) as AXValue?,
          AXValueGetValue(p, .cgPoint, &origin), AXValueGetValue(s, .cgSize, &size) else { return nil }
    return CGRect(origin: origin, size: size)
}

func close(_ a: CGRect, _ b: CGRect) -> Bool {
    abs(a.minX - b.minX) < 2 && abs(a.minY - b.minY) < 2 && abs(a.width - b.width) < 2 && abs(a.height - b.height) < 2
}

typealias Entry = (app: NSRunningApplication, window: AXUIElement)

/// Visible standard windows of every instance, front to back across instances.
/// The window server gives the global order; Accessibility gives the handles. They are matched by frame.
func orderedWindows() -> [Entry] {
    var axWindows: [pid_t: [(AXUIElement, CGRect)]] = [:]
    for app in instances {
        let windows = attr(AXUIElementCreateApplication(app.processIdentifier), kAXWindowsAttribute) as [AXUIElement]? ?? []
        axWindows[app.processIdentifier] = windows.compactMap { w in
            guard (attr(w, kAXSubroleAttribute) as String?) == kAXStandardWindowSubrole,
                  (attr(w, kAXMinimizedAttribute) as Bool?) != true else { return nil }
            return (w, instances.count > 1 ? frame(of: w) ?? .null : .null)
        }
    }
    // One process: Accessibility already lists its windows front to back, skip the slower matching.
    if instances.count == 1 { return axWindows[instances[0].processIdentifier]!.map { (instances[0], $0.0) } }
    let onScreen = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
    var result: [Entry] = []
    for info in onScreen where (info[kCGWindowLayer as String] as? Int) == 0 {
        guard let pid = info[kCGWindowOwnerPID as String] as? pid_t,
              let app = instances.first(where: { $0.processIdentifier == pid }),
              let dict = info[kCGWindowBounds as String] as? NSDictionary,
              let bounds = CGRect(dictionaryRepresentation: dict as CFDictionary),
              let i = axWindows[pid]?.firstIndex(where: { close($0.1, bounds) }) else { continue }
        result.append((app, axWindows[pid]!.remove(at: i).0))
    }
    return result
}

func bringToFront(_ app: NSRunningApplication, raising window: AXUIElement? = nil) {
    // Unhide first: a hidden app ignores the frontmost request.
    if app.isHidden {
        app.unhide()
        usleep(60_000)
    }
    if let window { AXUIElementPerformAction(window, kAXRaiseAction as CFString) }
    // Same mechanism as System Events' `set frontmost`; unlike NSRunningApplication.activate()
    // it is not subject to macOS 14+ cooperative-activation limits.
    AXUIElementSetAttributeValue(AXUIElementCreateApplication(app.processIdentifier), kAXFrontmostAttribute as CFString, kCFBooleanTrue)
}

let frontPid = NSWorkspace.shared.frontmostApplication?.processIdentifier
let windows = orderedWindows()

guard let current = instances.first(where: { $0.processIdentifier == frontPid }) else {
    // Not in front: top window of the group, or a hidden instance if nothing is visible.
    if let top = windows.first {
        bringToFront(top.app, raising: top.window)
    } else {
        bringToFront(instances.first(where: { $0.isHidden }) ?? instances[0])
    }
    exit(0)
}

switch windows.count {
case 0: openApp()
case 1: current.hide()
default:
    // Raising the back-most window rotates the whole stack.
    let last = windows[windows.count - 1]
    bringToFront(last.app, raising: last.window)
}
