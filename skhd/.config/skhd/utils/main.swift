// skhd-utils: small native helpers for the skhd hotkeys, one binary with a subcommand each.
//
//   skhd-utils cycle-app "<App Name>"
//   skhd-utils place-window "<App Name>" "<title substring>" [<width> <height>]
//   skhd-utils picker [-p <placeholder>] [-n <rows>] [-w <percent>]   (choices on stdin)
//
// Each command is documented in its own file. Build (binary goes to ~/.local/bin):
//   `mise run skhd-build`, or by hand from this directory:
//   swiftc -O -swift-version 5 -o ~/.local/bin/skhd-utils *.swift
//
// cycle-app and place-window need Accessibility permission; when launched from skhd they
// inherit skhd's.

import Foundation

let usage = """
    usage: skhd-utils cycle-app "<App Name>"
           skhd-utils place-window "<App Name>" "<title substring>" [<width> <height>]
           skhd-utils picker [-p <placeholder>] [-n <rows>] [-w <percent>]
    """

let args = Array(CommandLine.arguments.dropFirst())
switch args.first {
case "cycle-app" where args.count == 2: cycleApp(args[1])
case "place-window" where args.count == 3 || args.count == 5: placeWindow(Array(args.dropFirst()))
case "picker": runPicker(Array(args.dropFirst()))
default:
    printError(usage)
    exit(2)
}
