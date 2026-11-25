// picker: small AppKit launcher-style chooser, a possible replacement for `choose` (choose-gui).
// NOT wired into any script.
//
//   printf 'Spotify\ncliamp\n' | picker -p "Search music" -n 2 -w 20
//
//   -p <text>  placeholder shown in the search field
//   -n <rows>  max visible rows (default 8)
//   -w <pct>   window width as a percentage of the screen (default 20, never below 420 pt)
//
// Reads the choices from stdin, one per line, and prints the chosen one to stdout.
// Type to filter (fuzzy), Up/Down to move, Return to pick, Esc or click away to cancel (exit 1).
// Look: translucent rounded panel, search icon, accent-colored rounded selection; follows the
// system light/dark appearance and accent color.
//
// To try it in music-picker.sh, swap `/opt/homebrew/bin/choose` for `~/.config/skhd/scripts/picker`.
// To drop the experiment: delete this file and the `picker` line in .gitignore.
//
// Build (binary is git-ignored, rebuild after editing):
//   swiftc -O -swift-version 5 -o ~/.config/skhd/scripts/picker ~/.config/skhd/scripts/picker.swift

import AppKit

var prompt = "Search"
var maxRows = 8
var widthPercent = 20.0
var argv = CommandLine.arguments.dropFirst()
while let flag = argv.popFirst() {
    let value = argv.popFirst() ?? ""
    switch flag {
    case "-p": prompt = value
    case "-n": maxRows = Int(value) ?? maxRows
    case "-w": widthPercent = Double(value) ?? widthPercent
    default: break
    }
}

let choices = String(decoding: FileHandle.standardInput.readDataToEndOfFile(), as: UTF8.self)
    .split(separator: "\n").map(String.init).filter { !$0.isEmpty }
guard !choices.isEmpty else { exit(1) }

/// Every character of `query` appears in `text`, in order (case-insensitive).
func fuzzyMatch(_ query: String, in text: String) -> Bool {
    var rest = text.lowercased()[...]
    for ch in query.lowercased() {
        guard let i = rest.firstIndex(of: ch) else { return false }
        rest = rest[rest.index(after: i)...]
    }
    return true
}

// Borderless panels refuse key status by default, which would leave the text field deaf.
final class Panel: NSPanel {
    override var canBecomeKey: Bool { true }
}

/// Rounded, accent-colored selection instead of the default full-width bar.
final class RowView: NSTableRowView {
    override var isEmphasized: Bool { get { true } set {} }  // keep the text white even when unfocused
    override func drawSelection(in dirtyRect: NSRect) {
        guard isSelected else { return }
        NSColor.controlAccentColor.setFill()
        NSBezierPath(roundedRect: bounds.insetBy(dx: 8, dy: 2), xRadius: 9, yRadius: 9).fill()
    }
}

final class Picker: NSObject, NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate {
    let searchHeight: CGFloat = 58, rowHeight: CGFloat = 40, listInset: CGFloat = 8
    let panel: Panel
    let icon = NSImageView()
    let field = NSTextField()
    let divider = NSView()
    let table = NSTableView()
    let scroll = NSScrollView()
    var shown = choices
    var finished = false

    override init() {
        let screen = NSScreen.main?.frame ?? NSScreen.screens[0].frame
        let width = max(420, screen.width * widthPercent / 100)
        panel = Panel(contentRect: NSRect(x: 0, y: 0, width: width, height: 100),
                      styleMask: [.borderless], backing: .buffered, defer: false)
        super.init()

        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.delegate = self

        let background = NSVisualEffectView()
        background.material = .popover
        background.state = .active
        background.wantsLayer = true
        background.layer?.cornerRadius = 16
        background.layer?.cornerCurve = .continuous
        background.layer?.masksToBounds = true
        background.layer?.borderWidth = 1
        background.layer?.borderColor = NSColor.separatorColor.cgColor
        panel.contentView = background

        let symbol = NSImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        icon.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: nil)?
            .withSymbolConfiguration(symbol)
        icon.contentTintColor = .secondaryLabelColor
        background.addSubview(icon)

        field.placeholderString = prompt
        field.font = .systemFont(ofSize: 22, weight: .light)
        field.isBordered = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.delegate = self
        background.addSubview(field)

        divider.wantsLayer = true
        divider.layer?.backgroundColor = NSColor.separatorColor.cgColor
        background.addSubview(divider)

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("choice"))
        column.isEditable = false
        table.addTableColumn(column)
        table.headerView = nil
        table.style = .plain  // the default (.inset) adds its own 16 pt side and 10 pt top/bottom padding
        table.rowHeight = rowHeight
        table.intercellSpacing = .zero
        table.backgroundColor = .clear
        table.dataSource = self
        table.delegate = self
        table.target = self
        table.action = #selector(rowClicked)
        scroll.documentView = table
        scroll.drawsBackground = false
        scroll.scrollerStyle = .overlay
        background.addSubview(scroll)

        relayout()
        table.selectRowIndexes([0], byExtendingSelection: false)

        // Upper part of the screen, like Spotlight.
        let size = panel.frame.size
        panel.setFrameOrigin(NSPoint(x: screen.midX - size.width / 2,
                                     y: screen.maxY - screen.height * 0.25 - size.height))
    }

    /// Grow/shrink the panel to the number of matches, keeping its top edge in place.
    func relayout() {
        let rows = min(shown.count, maxRows)
        let listHeight = CGFloat(rows) * rowHeight
        let height = searchHeight + (rows > 0 ? 1 + listInset + listHeight + listInset : 0)
        var frame = panel.frame
        frame.origin.y += frame.height - height
        frame.size.height = height
        panel.setFrame(frame, display: true)
        panel.invalidateShadow()  // otherwise the old, taller shadow lingers after the list shrinks
        scroll.hasVerticalScroller = shown.count > maxRows

        let top = height - searchHeight
        icon.frame = NSRect(x: 20, y: top + (searchHeight - 22) / 2, width: 22, height: 22)
        field.frame = NSRect(x: 52, y: top + (searchHeight - 30) / 2, width: frame.width - 52 - 20, height: 30)
        divider.frame = NSRect(x: 0, y: top - 1, width: frame.width, height: 1)
        divider.isHidden = rows == 0
        scroll.frame = NSRect(x: 0, y: listInset, width: frame.width, height: listHeight)
        scroll.isHidden = rows == 0
        table.tableColumns[0].width = frame.width
    }

    func finish(_ code: Int32, output: String? = nil) {
        guard !finished else { return }
        finished = true
        if let output { print(output) }
        exit(code)
    }

    @objc func rowClicked() { pick() }

    func pick() {
        let row = table.selectedRow
        if shown.indices.contains(row) { finish(0, output: shown[row]) }
    }

    func move(_ delta: Int) {
        guard !shown.isEmpty else { return }
        let row = min(max(table.selectedRow + delta, 0), shown.count - 1)
        table.selectRowIndexes([row], byExtendingSelection: false)
        table.scrollRowToVisible(row)
    }

    // MARK: NSTextFieldDelegate
    func controlTextDidChange(_ obj: Notification) {
        let query = field.stringValue
        shown = query.isEmpty ? choices : choices.filter { fuzzyMatch(query, in: $0) }
        table.reloadData()
        relayout()
        if !shown.isEmpty { table.selectRowIndexes([0], byExtendingSelection: false) }
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
        switch selector {
        case #selector(NSResponder.moveDown(_:)): move(1)
        case #selector(NSResponder.moveUp(_:)): move(-1)
        case #selector(NSResponder.insertNewline(_:)): pick()
        case #selector(NSResponder.cancelOperation(_:)): finish(1)
        default: return false
        }
        return true
    }

    // MARK: NSTableViewDataSource / NSTableViewDelegate
    func numberOfRows(in tableView: NSTableView) -> Int { shown.count }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? { RowView() }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = NSTableCellView()
        let label = NSTextField(labelWithString: shown[row])
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.lineBreakMode = .byTruncatingTail
        label.frame = NSRect(x: 22, y: (rowHeight - 20) / 2, width: tableView.bounds.width - 44, height: 20)
        label.autoresizingMask = [.width]
        cell.addSubview(label)
        cell.textField = label  // lets AppKit flip the text to white on the selected row
        return cell
    }

    // MARK: NSWindowDelegate
    func windowDidResignKey(_ notification: Notification) { finish(1) }  // clicked away
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)  // no Dock icon
let picker = Picker()
picker.panel.alphaValue = 0
picker.panel.makeKeyAndOrderFront(nil)
picker.panel.makeFirstResponder(picker.field)
NSAnimationContext.runAnimationGroup { context in
    context.duration = 0.12
    picker.panel.animator().alphaValue = 1
}
// A background-launched process (skhd) can't take focus through NSApp.activate on macOS 14+,
// so also ask for it through Accessibility (needs the permission skhd already has).
app.activate(ignoringOtherApps: true)
if AXIsProcessTrusted() {
    AXUIElementSetAttributeValue(AXUIElementCreateApplication(getpid()), kAXFrontmostAttribute as CFString, kCFBooleanTrue)
}
app.run()
