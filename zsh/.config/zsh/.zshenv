# Sourced by every zsh invocation (interactive, non-interactive, scripts) —
# unlike .zshrc, which only runs for interactive shells. XDG vars and history
# location need to apply everywhere, so they live here. Reached via
# $ZDOTDIR, set by the tiny ~/.zshenv stub.
#
# HISTFILE/HISTSIZE/SAVEHIST are reasserted again in .zshrc (see comment
# there) — this copy is what actually applies to non-interactive/script
# shells, which never reach .zshrc.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=50000
export SAVEHIST=50000
