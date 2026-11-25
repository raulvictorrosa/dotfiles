#!/bin/sh
# alt+shift+m: pick Spotify or cliamp
# needs ~/.local/bin/skhd-utils (build: `mise run skhd-build`)
# (previous picker: printf ... | /opt/homebrew/bin/choose -p "Music" -n 2 -w 20)
pick=$(printf 'Spotify\ncliamp\n' | ~/.local/bin/skhd-utils picker -p "Search music" -n 2 -w 20) || exit 0

case "$pick" in
Spotify)
  open -a Spotify
  ;;
cliamp)
  if pgrep -f "[g]hostty --title=cliamp" >/dev/null; then
    # already open: only focus it, so a resized or maximized window keeps its size
    ~/.local/bin/skhd-utils place-window Ghostty cliamp
  else
    open -n -a Ghostty --args --title=cliamp -e cliamp
    # wait for the window, center it (875x600, upper third of the screen) and bring it to front
    ~/.local/bin/skhd-utils place-window Ghostty cliamp 875 600
  fi
  ;;
esac
