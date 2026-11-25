// Helpers shared by the skhd-utils commands.

import AppKit
import ApplicationServices

func printError(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
}

/// `open -a <name>`: launches the app, or reopens a window of a running one.
func openApp(_ name: String) -> Never {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    p.arguments = ["-a", name]
    try? p.run()
    p.waitUntilExit()
    exit(p.terminationStatus)
}

/// Running regular apps whose displayed name or .app bundle name is `name`, case-insensitively
/// like `open -a` ("Code" is displayed for the "Visual Studio Code" app). `open -n` starts a
/// separate process per window, so there can be several.
func runningInstances(of name: String) -> [NSRunningApplication] {
    NSWorkspace.shared.runningApplications.filter { app in
        app.activationPolicy == .regular
            && [app.localizedName, app.bundleURL?.deletingPathExtension().lastPathComponent]
                .contains { $0?.caseInsensitiveCompare(name) == .orderedSame }
    }
}

func axAttribute<T>(_ element: AXUIElement, _ key: String) -> T? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, key as CFString, &value) == .success else { return nil }
    return value as? T
}

func axElement(of app: NSRunningApplication) -> AXUIElement {
    AXUIElementCreateApplication(app.processIdentifier)
}

/// Bring `app` to front, optionally raising one of its windows first.
func bringToFront(_ app: NSRunningApplication, raising window: AXUIElement? = nil) {
    // Unhide first: a hidden app ignores the frontmost request.
    if app.isHidden {
        app.unhide()
        usleep(60_000)
    }
    if let window { AXUIElementPerformAction(window, kAXRaiseAction as CFString) }
    // Same mechanism as System Events' `set frontmost`; unlike NSRunningApplication.activate()
    // it is not subject to macOS 14+ cooperative-activation limits.
    AXUIElementSetAttributeValue(axElement(of: app), kAXFrontmostAttribute as CFString, kCFBooleanTrue)
}
