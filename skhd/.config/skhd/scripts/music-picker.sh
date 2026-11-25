#!/bin/sh
# alt+shift+m: pick Spotify or cliamp
# needs ~/.local/bin/picker and ~/.local/bin/place-window (build: `mise run skhd-build`)
# (previous picker: printf ... | /opt/homebrew/bin/choose -p "Music" -n 2 -w 20)
pick=$(printf 'Spotify\ncliamp\n' | ~/.local/bin/picker -p "Search music" -n 2 -w 20) || exit 0

case "$pick" in
Spotify)
  open -a Spotify
  ;;
cliamp)
  pgrep -f "Ghostty.*cliamp" >/dev/null ||
    open -n -a Ghostty --args --title="cliamp" -e cliamp
  # wait for the window, center it (875x600, upper third of the screen) and bring it to front
  ~/.local/bin/place-window Ghostty cliamp 875 600
  ;;
esac
