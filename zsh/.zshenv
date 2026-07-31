# zsh resolves $ZDOTDIR (or falls back to $HOME) once, before sourcing
# .zshenv — so this file can't live under .config/zsh itself, and setting
# ZDOTDIR here does NOT make zsh re-read .zshenv from the new location; it
# only affects .zprofile/.zshrc/.zlogin, which are looked up fresh. So the
# real .zshenv content is sourced explicitly below.
export ZDOTDIR="$HOME/.config/zsh"
[[ -f "$ZDOTDIR/.zshenv" ]] && source "$ZDOTDIR/.zshenv"
