# 🏠 Dotfiles

A comprehensive collection of configuration files for a productive development environment, featuring modern terminal tools, text editors, and window management.

## 🌟 Currently Recommended Setup (macOS)

The following tools are actively used and recommended for the best experience:

- **📝 Editors**: Neovim, VS Code
- **🪟 Window Management**: Rectangle, skhd, Borders (Aerospace tracked but currently unused — beta lag)
- **📊 System Monitoring**: SketchyBar
- **📁 File Navigation**: Yazi
- **🕰️ History**: Atuin
- **🔄 Multiplexer**: tmux, herdr (trialing both, undecided which one sticks)
- **🗂️ Session Management**: tmuxinator (for tmux), herdr-plus/sessionizer/navigator (for herdr)
- **✨ Terminal**: Ghostty
- **🐭 Mouse**: LinearMouse
- **📦 Tools**: Mise, Homebrew
- **🤖 AI**: Claude Code

## ✨ What's Inside

### 🛠️ Core Tools

- **Terminal**: Ghostty (recommended), Kitty, WezTerm configurations; Alacritty (reference only)
- **Shell**: Zsh with Antidote and Starship — a few individual oh-my-zsh plugins (`git`, `vi-mode`, `eza`, `tmux`, `tmuxinator`) loaded standalone, no framework
- **Multiplexer**: tmux with TPM plugin manager, config split under `tmux/.config/tmux/conf.d/` (options/bindings/statusbar/plugins), bindings adapted from [omarchy](https://github.com/basecamp/omarchy)'s tmux.conf — herdr is being trialed alongside it, see "Session & Workspace Management" below
- **File Management**: Atuin (history), Yazi (directory navigation)

### 🗂️ Session & Workspace Management

Trialing two project-session tools side by side before picking one:

- **tmuxinator**: one YAML per project in `tmuxinator/.config/tmuxinator/` (via the `omz` plugin: `txs`/`txo`/`txn`/`txl` aliases). Start with `tmuxinator start <name>` or `txs <name>`.
- **herdr**: agent-aware terminal multiplexer, config in `herdr/.config/herdr/`. Four plugins installed:
  - [herdr-plus](https://github.com/cloudmanic/herdr-plus) — the tmuxinator equivalent: one TOML per project in `plugins/config/cloudmanic.herdr-plus/projects/`, plus a quick-actions fuzzy launcher. Bound to `prefix+up` (projects) / `prefix+down` (quick actions) — herdr's own prefix, default `ctrl+b` — or headlessly with `herdr-plus open <name>`.
  - [herdr-sessionizer](https://github.com/andrewchng/herdr-sessionizer) — fzf-style picker over arbitrary project roots / git worktrees, bound to `prefix+f` (`prefix+shift+f` for the worktree picker).
  - [herdr-navigator](https://github.com/thanhdat77/herdr-navigator) — unified fuzzy "jump to anything" (workspaces, agents, projects, sessions, dirs, actions) with a preview toggle, bound to `prefix+t`.
  - [herdr-lazy](https://github.com/natori-hrj/herdr-lazy) — declarative plugin manager for the other three: `plugins/config/herdr-lazy/plugins.list` (tracked) declares the set, `plugins.lock` (tracked) pins commits. Manage pane bound to `prefix+shift+l`. On a new machine: `herdr plugin install natori-hrj/herdr-lazy --yes`, then `herdr-lazy sync` (see that file for the binary-path trick — it isn't on `PATH`).

Client-confidential project files (e.g. work projects outside personal ones) are kept on disk inside these same directories — visible via `ls`, but ignored via `.git/info/exclude` (local-only, never committed) instead of the tracked `.gitignore`, so their names never end up in git history.

### 🎨 Development Environment

- **Neovim**: LazyVim-based configuration with LSP support (recommended)
- **VS Code**: Modern editor with extensions (recommended)
- **Vim**: Classic Vim setup with vim-plug (reference)
- **Zed**: Modern code editor configuration (alternative)

### 🪟 Desktop & UI

- **Rectangle**: Window snapping/positioning (macOS) — the active window-management tool
- **SketchyBar**: Custom menu bar with system monitors (macOS)
- **Borders**: Window border customization (macOS)
- **LinearMouse**: Mouse acceleration customization (macOS)
- **Aerospace**: Tiling window manager (macOS) — tracked but currently unused; still in beta and was causing lag, may revisit later
- **Amethyst**: Alternative tiling window manager (macOS - reference only)

👆 *[Quick setup: Jump to installation guide](#installation)*

### 📦 Package Management

- **Homebrew**: Centralized package management via Brewfile (macOS)
- **Mise**: Development tool version management

### 🤖 AI Tools

- **Claude Code**: MCP servers config (Atlassian, GitHub, Figma, Azure, Playwright, Context7, Crowdin, and more) + Caveman plugin

### 🔧 Additional Tools

- **Git**: Portable gitconfig with machine-local identity override pattern
- **Lazygit**: Terminal UI for git
- **K9s**: Kubernetes cluster management
- **SKHD**: Hotkey daemon for app toggles (Chrome, VS Code, Ghostty/Neovim, Finder, Spotify, btop) — window snapping is handled separately by Rectangle, not a tiling window manager
- **Witr**: Traces a running process/port/container/file back to what started it

## 🚀 Quick Start

### Prerequisites

- macOS or Linux (configs support both platforms)
- [Homebrew](https://brew.sh/) installed (macOS) or equivalent package manager

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/raulvictorrosa/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install packages via Homebrew**

   ```bash
   cd brew
   brew bundle install
   ```

3. **Create symlinks using Stow**

   ```bash
   # Install stow if not already installed
   brew install stow

   # Recommended: Link only the currently recommended configs
   stow nvim zsh tmux ghostty mise atuin git starship tmuxinator herdr  # Core tools
   stow aerospace sketchybar borders linearmouse skhd  # macOS window management
   stow k9s btop lazygit  # Terminal TUIs
   stow claude  # AI tools

   # Git: copy the local identity template and fill in your details
   cp ~/dotfiles/git/.config/git/config.local.example ~/.config/git/config.local
   # then edit ~/.config/git/config.local with your name and email

   # Alternative: Create symlinks for all configs
   stow */
   ```

4. **Restart your shell**

   ```bash
   exec zsh
   ```

## 📁 Directory Structure

```text
├── aerospace/          # Tiling window manager (macOS, tracked but currently unused — beta lag)
├── alacritty/         # GPU-accelerated terminal emulator (uninstalled, kept for reference)
├── amethyst/          # Alternative tiling window manager (macOS - unused, kept for reference)
├── atuin/             # Shell history manager
├── borders/           # Window border customization
├── brew/              # Package management (mainly for macOS)
│   ├── Brewfile       # All installed packages/apps
│   └── README.md      # Package management guide
├── btop/              # System monitor (terminal)
├── claude/            # Claude Code AI assistant config
├── git/               # Git config (portable; identity goes in ~/.config/git/config.local)
├── ghostty/           # Terminal emulator
├── herdr/             # Agent-aware multiplexer config + herdr-plus/sessionizer plugin projects
├── k9s/               # Kubernetes cluster manager
├── kitty/             # Terminal emulator
├── lazygit/           # Terminal UI for git
├── linearmouse/       # Mouse settings (macOS)
├── mise/              # Development tool version manager
├── nvim/              # Neovim editor configuration
├── sketchybar/        # Custom menu bar (macOS)
├── skhd/              # Hotkey daemon for app toggles (macOS)
├── starship/          # Prompt config (starship, minimal built-in defaults)
├── tmux/              # Terminal multiplexer (tmux.conf sources conf.d/*.conf)
├── tmuxinator/        # Per-project tmux session layouts (YAML)
├── vim/               # Classic Vim configuration
├── wezterm/           # Terminal emulator
├── zed/               # Modern code editor
└── zsh/               # Zsh shell configuration
```

## 🎯 Key Features

### Shell Experience

- **Dracula theme** throughout most applications
- **Starship** prompt with git integration
- **Antidote** for static, fast plugin management (replacing Zinit)
- **VI mode** enabled in zsh
- **Smart history** with Atuin
- **Directory navigation** with Yazi file manager

### Development Setup

- **Modern text editing** with Neovim + LazyVim
- **Multiple terminal options** (Ghostty, Kitty, WezTerm; Alacritty kept for reference)
- **Window snapping** with Rectangle, app-toggle hotkeys with skhd (macOS) — Aerospace tracked for later, currently unused (beta lag)
- **Kubernetes management** with K9s
- **Version management** with Mise

### System Integration

- **Custom menu bar** with SketchyBar showing system stats (macOS)
- **Window borders** for better visual separation (macOS)
- **App-toggle hotkeys** built into skhd (macOS)
- **Cross-platform package management** with Homebrew/system package managers

## ⚙️ Configuration Highlights

### Git Configuration

Portable setup that works across machines with different identities. Config
lives under `$XDG_CONFIG_HOME/git/` (native git XDG fallback — only used
when `~/.gitconfig` doesn't exist, which is why it's important not to
recreate one):

- `git/.config/git/config` — shared settings: delta pager, default branch, merge strategy
- `git/.config/git/ignore` — global ignores (`.DS_Store`, swap files)
- `~/.config/git/config.local` — machine-specific identity, **not committed**

On a new machine, after `stow git`:

```bash
cp ~/dotfiles/git/.config/git/config.local.example ~/.config/git/config.local
# edit with your name and email
```

The shared config includes `[include] path = ~/.config/git/config.local` so git picks up identity automatically.

### macOS Gotchas

**tmux prefix (`C-Space`) doesn't fire.** macOS reserves `Ctrl+Space` /
`Ctrl+Option+Space` system-wide for switching input sources — it never
reaches the terminal. Disable it in **System Settings → Keyboard →
Keyboard Shortcuts → Input Sources** (uncheck "Select the previous input
source" and "Select next input source"), or from the CLI:

```bash
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:60:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:61:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist
killall SystemUIServer cfprefsd
```

### XDG Base Directory Compliance

Tools already managed by this repo are kept XDG-compliant where the tool
supports it (this is a scoped pass over dotfiles-managed tools, not a
machine-wide reorg):

- **zsh**: env vars (`XDG_*`, `HISTFILE`) live in `zsh/.zshenv`, sourced by
  *every* zsh invocation — not just interactive ones, unlike `.zshrc`. Shell
  history lives at `$XDG_STATE_HOME/zsh/history` instead of `~/.zsh_history`.
- **git**: config relocated to `$XDG_CONFIG_HOME/git/` (see Git Configuration
  above) instead of `~/.gitconfig`.
- **atuin, mise, lazygit, yazi, nvim, tmux**: already XDG-compliant natively
  (config under `.config/`, data/state/cache under their respective XDG dirs)
  — no changes needed.

### SketchyBar Features

- CPU and memory monitoring
- Network usage display
- Battery status
- Calendar integration
- Media controls
- Custom app icons

### Neovim Setup

- LazyVim as the base configuration
- LSP support for multiple languages
- Custom keybindings for VSCode compatibility

### Terminal Features

- Dracula colorscheme across all terminals
- JetBrains Mono Nerd Font
- Custom font sizes and settings optimized for each terminal

## 🔄 Maintenance

### Updating Packages

```bash
# Update Homebrew packages
cd ~/dotfiles/brew
brew bundle install --cleanup

# Update Brewfile with new packages
brew bundle dump --force
```

### Sync Configurations

After making changes to any config:

```bash
cd ~/dotfiles
git add .
git commit -m "Update configurations"
git push
```

## 🤝 Contributing

Feel free to:

- Fork this repository
- Submit pull requests for improvements
- Open issues for bugs or feature requests
- Share your own customizations

## 📝 Notes

- Configurations support both macOS and Linux environments
- Some platform-specific tools (Aerospace, SketchyBar, LinearMouse) are macOS-only
- Font requirements: JetBrains Mono Nerd Font (installed via package manager)
- Rectangle + skhd currently handle window management on macOS; Aerospace is tracked in the Brewfile/repo but not in use (still in beta, was causing lag)
- **If you do switch to Aerospace**: it disables macOS native word navigation (Option+arrow keys) due to hotkey conflicts

## 📚 Useful Commands

```bash
# Reload zsh configuration
source ~/.zshrc

# Restart Aerospace (macOS window manager, if you're using it instead of Rectangle)
aerospace reload-config

# Rebuild SketchyBar (macOS)
sketchybar --reload

# View tmux sessions
tmux list-sessions

# Open file with default editor (nvim)
$EDITOR filename

# Stow/unstow configurations
stow zsh nvim tmux  # Link specific configs
stow -D zsh         # Unlink zsh config
```

---

**Happy coding!** 🎉
