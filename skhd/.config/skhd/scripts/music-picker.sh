#!/bin/sh
# alt+shift+m: pick Spotify or cliamp
# needs `choose` (choose-gui) and scripts/place-window (build: see place-window.swift)
pick=$(printf 'Spotify\ncliamp\n' | /opt/homebrew/bin/choose -p "Music" -n 2 -w 20) || exit 0

case "$pick" in
Spotify)
  open -a Spotify
  ;;
cliamp)
  pgrep -f "Ghostty.*cliamp" >/dev/null ||
    open -n -a Ghostty --args --title="cliamp" -e cliamp
  # wait for the window, center it (875x600, upper third of the screen) and bring it to front
  ~/.config/skhd/scripts/place-window Ghostty cliamp 875 600
  ;;
esac
