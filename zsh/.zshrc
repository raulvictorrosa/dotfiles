# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Starship (initialized below) is the active prompt; skip oh-my-zsh's own
# theme rendering entirely instead of loading one that's never shown.
ZSH_THEME=""

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
plugins=(
  git
  history
  vi-mode
)

# Docker CLI completions fpath must be added before compinit runs (inside
# oh-my-zsh.sh below) so a single compinit pass picks them up — avoids a
# second, redundant compinit call later in this file.
fpath=($HOME/.docker/completions $fpath)

source $ZSH/oh-my-zsh.sh

# User configuration

# Antidote — static plugin bundle (replaces zinit). Reads
# ${ZDOTDIR:-$HOME}/.zsh_plugins.txt, clones on first run, and generates a
# compiled ~/.zsh_plugins.zsh that's just sourced on subsequent starts — no
# per-plugin runtime resolution. `brew --prefix` resolves correctly across
# Apple Silicon (/opt/homebrew), Intel Mac (/usr/local), and Linuxbrew
# (/home/linuxbrew/.linuxbrew); the manual-clone path covers Linux boxes
# without Homebrew at all (antidote's own non-brew install method).
if command -v brew >/dev/null 2>&1; then
  source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
elif [[ -f "$HOME/.antidote/antidote.zsh" ]]; then
  source "$HOME/.antidote/antidote.zsh"
fi
antidote load

# Cache the output of tools whose shell integration is normally loaded via a
# synchronous `eval "$(... init zsh)"` — that spawns the binary on every
# shell start. Instead, write the generated script to a cache file once and
# just `source` it, regenerating only when the binary itself changes.
_zsh_cached_eval_init() {
  local cache="$XDG_CACHE_HOME/zsh/$1-init.zsh" bin
  bin="$(command -v "$1")" || return
  [[ -s "$cache" && "$cache" -nt "$bin" ]] || { mkdir -p "${cache:h}"; "$@" > "$cache"; }
  source "$cache"
}

# Starship — cross-shell prompt (replaces Powerlevel10k)
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship-default.toml"
_zsh_cached_eval_init starship init zsh

# Atuin - History Manager
_zsh_cached_eval_init atuin init zsh

# mise - polyglot runtime manager (replaces oh-my-zsh's mise plugin eval)
_zsh_cached_eval_init mise activate zsh

# worktrunk - Git worktree management CLI
command -v wt >/dev/null 2>&1 && _zsh_cached_eval_init wt config shell init zsh

# fzf -- a command-line fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Broot is a better way to navigate directories, find files, and launch commands.
[ -f $HOME/.config/broot/launcher/bash/br ] && source $HOME/.config/broot/launcher/bash/br

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

alias ls='eza --icons=always'
alias cat='bat'
alias vim='nvim'
alias trs='tmux rename-session'

export VISUAL=nvim;
export EDITOR=nvim;

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Opt out of Azure MCP / Copilot skills telemetry
export AZURE_MCP_COLLECT_TELEMETRY=false

# Required for claude CLI and poetry — both install to ~/.local/bin and won't be found without this
export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.cache/lm-studio/bin"
