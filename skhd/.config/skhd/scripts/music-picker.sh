#!/bin/sh
# alt+shift+m: pick Spotify or cliamp (needs `choose`, from choose-gui)
pick=$(printf 'Spotify\ncliamp\n' | /opt/homebrew/bin/choose -p "Music" -n 2 -w 20) || exit 0

case "$pick" in
Spotify)
  open -a Spotify
  ;;
cliamp)
  if pgrep -f "Ghostty.*cliamp" >/dev/null; then
    osascript -e 'tell application "Ghostty" to activate'
  else
    open -n -a Ghostty --args --title="cliamp" -e cliamp
  fi
  sleep 1
  # center a 875x600 window, upper third of the screen
  osascript \
    -e 'set window_width to 875' \
    -e 'set window_height to 600' \
    -e 'set process_name to "Ghostty"' \
    -e 'tell application "Finder" to set screen_bounds to bounds of window of desktop' \
    -e 'set screen_width to item 3 of screen_bounds' \
    -e 'set screen_height to item 4 of screen_bounds' \
    -e 'set x_pos to (screen_width - window_width) / 2' \
    -e 'set y_pos to ((screen_height - window_height) / 3)' \
    -e 'tell application "System Events"' \
    -e '  repeat with p in (every process whose name is process_name)' \
    -e '    repeat with w in windows of p' \
    -e '      if name of w contains "cliamp" then' \
    -e '        set size of w to {window_width, window_height}' \
    -e '        set position of w to {x_pos, y_pos}' \
    -e '        return' \
    -e '      end if' \
    -e '    end repeat' \
    -e '  end repeat' \
    -e 'end tell'
  ;;
esac
