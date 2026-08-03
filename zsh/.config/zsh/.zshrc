# ------------------------------------------------------------------
# Plugins — antidote (static bundle, see .zsh_plugins.txt). Only 3
# community plugins plus 3 individual oh-my-zsh plugins loaded standalone
# (git, vi-mode, eza) — no oh-my-zsh framework/core needed for any of them.
# ------------------------------------------------------------------

# eza plugin config must be set before antidote sources it below.
zstyle ':omz:plugins:eza' icons yes

# The git plugin (loaded below, before compinit) calls `compdef` to register
# its aliases' completions — but compinit hasn't defined the real `compdef`
# yet at that point. Queue those calls in a stub and replay them for real
# once compinit runs (this is the same ordering trick oh-my-zsh's own
# completion.zsh uses internally).
typeset -ga _zsh_deferred_compdefs
compdef() { _zsh_deferred_compdefs+=("$*") }

# zsh-completions (bundled below) adds to fpath; Docker's own completions
# need to land in fpath before compinit runs too, so both go in before
# `antidote load`. Docker Desktop's settings UI checks ~/.zshrc for its own
# literal marker snippet and will claim completions aren't installed even
# though they're wired up here — that check is cosmetic, safe to dismiss.
fpath=($HOME/.docker/completions $fpath)

# `brew --prefix` resolves correctly across Apple Silicon (/opt/homebrew),
# Intel Mac (/usr/local), and Linuxbrew (/home/linuxbrew/.linuxbrew); the
# manual-clone path covers Linux boxes without Homebrew at all (antidote's
# own non-brew install method).
if command -v brew >/dev/null 2>&1; then
  source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
elif [[ -f "$HOME/.antidote/antidote.zsh" ]]; then
  source "$HOME/.antidote/antidote.zsh"
fi
antidote load

# ------------------------------------------------------------------
# Completion
# ------------------------------------------------------------------
autoload -Uz compinit compdef
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# `autoload -Uz compdef` above already replaced the stub with the real one
# (confirmed — autoload overrides an existing ordinary function of the same
# name). Replay what the stub queued through it.
for _zsh_compdef_call in "${_zsh_deferred_compdefs[@]}"; do
  eval "compdef $_zsh_compdef_call"
done
unset _zsh_deferred_compdefs _zsh_compdef_call

# ------------------------------------------------------------------
# Prompt
# ------------------------------------------------------------------

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

# Starship — cross-shell prompt
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
_zsh_cached_eval_init starship init zsh

# ------------------------------------------------------------------
# Tool integrations
# ------------------------------------------------------------------

# Atuin - History Manager
_zsh_cached_eval_init atuin init zsh

# mise - polyglot runtime manager
_zsh_cached_eval_init mise activate zsh

# worktrunk - Git worktree management CLI
command -v wt >/dev/null 2>&1 && _zsh_cached_eval_init wt config shell init zsh

# fzf -- a command-line fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Dracula palette (draculatheme.com/fzf) — also picked up by anything else
# that shells out to fzf, e.g. herdr-sessionizer's picker.
export FZF_DEFAULT_OPTS="--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

# Broot is a better way to navigate directories, find files, and launch commands.
[ -f $HOME/.config/broot/launcher/bash/br ] && source $HOME/.config/broot/launcher/bash/br

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------
# ls/la/ll/etc. come from the eza oh-my-zsh plugin above.
alias cat='bat'
alias vim='nvim'
alias trs='tmux rename-session'

# ------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# ------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------
export VISUAL=nvim
export EDITOR=nvim

# Opt out of Azure MCP / Copilot skills telemetry
export AZURE_MCP_COLLECT_TELEMETRY=false

# Required for claude CLI and poetry — both install to ~/.local/bin and won't be found without this
export PATH="$HOME/.local/bin:$PATH"
