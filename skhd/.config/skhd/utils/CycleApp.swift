// skhd-utils cycle-app "<App Name>": focus-or-cycle helper for the app hotkeys.
//
//   app not running        -> open it
//   running, not in front  -> bring it to front
//   in front, >1 windows   -> raise the next window (rotates through all of them)
//   in front, 1 window     -> hide the app (like Cmd+H); the next press brings it back
//   in front, 0 windows    -> open it again (reopens a window)
//
// All running instances of the app count as one (`open -n -a Ghostty` starts a separate process
// per btop/cliamp/nvim window). Windows are ordered with the system-wide front-to-back list.

import AppKit
import ApplicationServices

private func axFrame(of window: AXUIElement) -> CGRect? {
    var origin = CGPoint.zero, size = CGSize.zero
    guard let p = axAttribute(window, kAXPositionAttribute) as AXValue?,
          let s = axAttribute(window, kAXSizeAttribute) as AXValue?,
          AXValueGetValue(p, .cgPoint, &origin), AXValueGetValue(s, .cgSize, &size) else { return nil }
    return CGRect(origin: origin, size: size)
}

private func sameFrame(_ a: CGRect, _ b: CGRect) -> Bool {
    abs(a.minX - b.minX) < 2 && abs(a.minY - b.minY) < 2 && abs(a.width - b.width) < 2 && abs(a.height - b.height) < 2
}

func cycleApp(_ name: String) -> Never {
    let instances = runningInstances(of: name)
    if instances.isEmpty { openApp(name) }

    guard AXIsProcessTrusted() else {
        printError("cycle-app: Accessibility permission missing")
        instances[0].activate()
        exit(1)
    }

    typealias Entry = (app: NSRunningApplication, window: AXUIElement)

    /// Visible standard windows of every instance, front to back across instances.
    /// The window server gives the global order; Accessibility gives the handles. They are matched by frame.
    func orderedWindows() -> [Entry] {
        var axWindows: [pid_t: [(AXUIElement, CGRect)]] = [:]
        for app in instances {
            let windows = axAttribute(axElement(of: app), kAXWindowsAttribute) as [AXUIElement]? ?? []
            axWindows[app.processIdentifier] = windows.compactMap { w in
                guard (axAttribute(w, kAXSubroleAttribute) as String?) == kAXStandardWindowSubrole,
                      (axAttribute(w, kAXMinimizedAttribute) as Bool?) != true else { return nil }
                return (w, instances.count > 1 ? axFrame(of: w) ?? .null : .null)
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
                  let i = axWindows[pid]?.firstIndex(where: { sameFrame($0.1, bounds) }) else { continue }
            result.append((app, axWindows[pid]!.remove(at: i).0))
        }
        return result
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
    case 0: openApp(name)
    case 1: current.hide()
    default:
        // Raising the back-most window rotates the whole stack.
        let last = windows[windows.count - 1]
        bringToFront(last.app, raising: last.window)
    }
    exit(0)
}
