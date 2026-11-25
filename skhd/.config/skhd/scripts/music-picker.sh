#!/bin/sh
# alt+shift+m: pick Spotify or cliamp
# needs scripts/picker and scripts/place-window (build: see picker.swift and place-window.swift)
# (previous picker: printf ... | /opt/homebrew/bin/choose -p "Music" -n 2 -w 20)
pick=$(printf 'Spotify\ncliamp\n' | ~/.config/skhd/scripts/picker -p "Search music" -n 2 -w 20) || exit 0

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
