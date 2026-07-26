# Powerlevel10k instant prompt — disabled now that starship is the active
# prompt. Kept commented (not deleted) as a rollback path; see
# docs/plans/starship-migration.md.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

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

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Non-prompt plugins load in Turbo mode (after the first prompt renders) so
# they don't block startup.
zi ice wait lucid; zi light zsh-users/zsh-autosuggestions
zi ice wait lucid; zi light zsh-users/zsh-completions
zi ice wait lucid; zi light zsh-users/zsh-syntax-highlighting
# Powerlevel10k retired in favor of starship — see docs/plans/starship-migration.md.
# Uncomment to roll back:
# zi ice depth=1; zi light romkatv/powerlevel10k

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

# Starship — cross-shell prompt (replaces Powerlevel10k; see
# docs/plans/starship-migration.md). Swap the filename below to try a
# different committed preset before picking one.
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship-pastel-powerline.toml"
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

# p10k rollback: uncomment to bring back the old prompt (also uncomment the
# instant-prompt block above and the `zi light romkatv/powerlevel10k` line).
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
