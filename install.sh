#!/usr/bin/env bash
# Bootstrap these dotfiles: clone the repo if needed, then symlink the packages
# with GNU Stow. Safe to run more than once. macOS and Linux only.
#
#   curl -fsSL https://raw.githubusercontent.com/raulvictorrosa/dotfiles/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/raulvictorrosa/dotfiles/main/install.sh | bash -s -- --brew
#
# Options:
#   --brew     also install everything in brew/Brewfile (macOS; large, includes GUI apps)
#   --dry-run  only show what Stow would link; installs and writes nothing
#
# Environment:
#   DOTFILES_DIR     where to clone when running through curl (default: ~/dotfiles)
#   XDG_CONFIG_HOME  where configs are linked (default: ~/.config)

set -euo pipefail

REPO_URL="https://github.com/raulvictorrosa/dotfiles.git"

# These lists are Stow packages: the configs that get linked, not the software
# that gets installed (that is brew/Brewfile, only with --brew).

# Packages that work on macOS and Linux
COMMON_PACKAGES=(
  atuin btop ghostty git herdr herdr-app hunk k9s lazygit mise nvim shiki
  starship television yazi zed zsh
)

# macOS-only packages
MAC_PACKAGES=(
  linearmouse skhd
)
# Tracked but not installed because they are unused: aerospace, borders, tmux,
# tmuxinator. sketchybar is also left out: its files are not under .config/, so
# Stow would link them into the wrong place.

# Apps write runtime files into these (relative to the config directory).
# Creating them first stops Stow from folding them into a single symlink that
# would send those files into the repo.
APP_MANAGED_DIRS=(
  herdr
  herdr-app/themes
)

die() {
  echo "ERROR: $*" >&2
  exit 1
}

is_mac() { [[ "$(uname -s)" == "Darwin" ]]; }

as_root() {
  if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

load_brew() {
  command -v brew &>/dev/null && return 0
  local brew_bin
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      return 0
    fi
  done
  return 1
}

ensure_brew() {
  load_brew && return 0
  echo "Installing Homebrew..."
  local installer
  installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Under `curl | bash` stdin is the pipe, so give the installer the terminal.
  if (: </dev/tty) 2>/dev/null; then
    /bin/bash -c "$installer" </dev/tty
  else
    NONINTERACTIVE=1 /bin/bash -c "$installer"
  fi
  load_brew || die "Homebrew was installed but 'brew' was not found"
}

install_packages() {
  if is_mac; then
    ensure_brew
    brew install "$@"
  elif command -v pacman &>/dev/null; then
    # No -y: refreshing the database without a full upgrade is unsupported on Arch.
    as_root pacman -S --needed --noconfirm "$@" ||
      die "pacman failed; update the system with 'sudo pacman -Syu', then run this again"
  elif command -v apt-get &>/dev/null; then
    as_root apt-get update
    as_root apt-get install -y "$@"
  elif command -v dnf &>/dev/null; then
    as_root dnf install -y "$@"
  else
    die "no supported package manager; install manually: $*"
  fi
}

# XDG base directory spec: use XDG_CONFIG_HOME only when it is an absolute path,
# otherwise fall back to the default.
config_home() {
  if [[ "${XDG_CONFIG_HOME:-}" == /* ]]; then
    echo "${XDG_CONFIG_HOME%/}"
  else
    echo "$HOME/.config"
  fi
}

# Link one package: its .config/ content goes to the config directory, and
# anything else (only zsh/.zshenv today) goes to $HOME.
stow_package() {
  local repo="$1" target="$2" pkg="$3"
  shift 3
  if [[ -d "$repo/$pkg/.config" ]]; then
    if [[ -d "$target" ]]; then
      stow "$@" --dir="$repo/$pkg" --target="$target" .config || return 1
    else
      # Only on a dry run: Stow rejects a missing target, and nothing in it can conflict.
      echo "  would link $repo/$pkg/.config/* into $target"
    fi
  fi
  if [[ -f "$repo/$pkg/.zshenv" ]]; then
    stow "$@" --dir="$repo" --target="$HOME" --ignore='\.config' "$pkg" || return 1
  fi
}

# skhd hotkeys call skhd-utils, which a mise task compiles from the Swift sources.
# A failure only warns: the configs are already linked at this point.
build_skhd_utils() {
  local configs="$1" retry="run 'mise run skhd-build' later"
  load_brew || true
  if ! command -v mise &>/dev/null || ! xcode-select -p &>/dev/null; then
    echo "WARNING: skhd-utils needs mise and the Xcode Command Line Tools; $retry" >&2
    return 0
  fi
  echo "Building skhd-utils..."
  # Without this, 'mise run' first installs every tool listed in the global config.
  (cd "$HOME" && XDG_CONFIG_HOME="$configs" MISE_TASK_RUN_AUTO_INSTALL=false mise run skhd-build) ||
    echo "WARNING: building skhd-utils failed; $retry" >&2
}

# Directory of this script when it runs from a checkout, empty when piped.
local_checkout() {
  local source="${BASH_SOURCE[0]:-}" dir
  [[ -f "$source" ]] || return 0
  dir="$(cd "$(dirname "$source")" && pwd)"
  if [[ -f "$dir/zsh/.zshenv" ]]; then echo "$dir"; fi
}

# Anything else (Git Bash, MSYS2, Cygwin on Windows, BSDs) stops before any change.
require_supported_os() {
  local os
  os="$(uname -s)"
  case "$os" in
    Darwin | Linux) ;;
    *) die "unsupported system '$os': only macOS and Linux are supported" ;;
  esac
}

main() {
  require_supported_os

  local with_brew=false dry_run=false arg
  for arg in "$@"; do
    case "$arg" in
      --brew) with_brew=true ;;
      --dry-run) dry_run=true ;;
      *) die "unknown option: $arg" ;;
    esac
  done

  local dir
  dir="$(local_checkout)"
  if [[ -z "$dir" ]]; then
    dir="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [[ ! -d "$dir/.git" ]]; then
      $dry_run && die "--dry-run needs an existing clone at $dir"
      command -v git &>/dev/null || install_packages git
      echo "Cloning into $dir..."
      git clone "$REPO_URL" "$dir"
    else
      echo "Using the existing clone at $dir (not pulling)"
    fi
  fi

  if ! command -v stow &>/dev/null; then
    load_brew || true
    if ! command -v stow &>/dev/null; then
      $dry_run && die "--dry-run needs stow installed"
      install_packages stow
    fi
  fi

  if $with_brew && ! $dry_run; then
    is_mac || die "--brew is only supported on macOS"
    ensure_brew
    # A single failing cask must not stop the dotfiles from being linked.
    brew bundle install --file="$dir/brew/Brewfile" ||
      echo "WARNING: some Brewfile entries failed to install" >&2
  fi

  local packages=("${COMMON_PACKAGES[@]}")
  if is_mac; then packages+=("${MAC_PACKAGES[@]}"); fi

  local configs
  configs="$(config_home)"
  echo "Linking configs into $configs"

  local stow_flags=(--ignore='\.DS_Store')
  if $dry_run; then
    stow_flags+=(--no --verbose)
  else
    local managed
    mkdir -p "$configs"
    for managed in "${APP_MANAGED_DIRS[@]}"; do
      mkdir -p "$configs/$managed"
    done
  fi

  # One package at a time, so a conflict in one does not block the others.
  local pkg failed=()
  for pkg in "${packages[@]}"; do
    echo "Stowing $pkg..."
    stow_package "$dir" "$configs" "$pkg" "${stow_flags[@]}" || failed+=("$pkg")
  done

  if is_mac && [[ " ${failed[*]-} " != *" skhd "* && " ${failed[*]-} " != *" mise "* ]]; then
    if $dry_run; then
      echo "Would build skhd-utils with: mise run skhd-build"
    else
      build_skhd_utils "$configs"
    fi
  fi

  local identity="$dir/git/.config/git/config.local"
  if ! $dry_run && [[ ! -e "$identity" ]]; then
    cp "$identity.example" "$identity"
    echo "Created $identity - edit it with your git name and email."
  fi
  if [[ -e "$HOME/.gitconfig" ]]; then
    echo "WARNING: ~/.gitconfig exists, so Git also reads it and it overrides $configs/git/config." >&2
  fi

  if ((${#failed[@]})); then
    echo "Not linked: ${failed[*]}" >&2
    die "move the conflicting files listed above out of the way, then run this again"
  fi

  echo "Done! Restart your shell with: exec zsh"
}

# Everything runs from main so a partially downloaded script does nothing.
main "$@"
