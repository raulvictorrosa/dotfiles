# 🏠 Dotfiles

A comprehensive collection of configuration files for a productive development environment, featuring modern terminal tools, text editors, and window management.

## 🌟 Currently Recommended Setup (macOS)

The following tools are actively used and recommended for the best experience:

- **📝 Editors**: Neovim, VS Code
- **🪟 Window Management**: Aerospace, Borders
- **📊 System Monitoring**: SketchyBar
- **📁 File Navigation**: Yazi
- **🕰️ History**: Atuin
- **🔄 Multiplexer**: tmux
- **✨ Terminal**: Ghostty
- **🐭 Mouse**: LinearMouse
- **📦 Tools**: Mise, Homebrew
- **🤖 AI**: Claude Code

## ✨ What's Inside

### 🛠️ Core Tools

- **Terminal**: Ghostty (recommended), Kitty, WezTerm configurations; Alacritty (reference only)
- **Shell**: Zsh with Antidote and Starship — a few individual oh-my-zsh plugins (`git`, `vi-mode`, `eza`) loaded standalone, no framework
- **Multiplexer**: tmux with TPM plugin manager
- **File Management**: Atuin (history), Yazi (directory navigation)

### 🎨 Development Environment

- **Neovim**: LazyVim-based configuration with LSP support (recommended)
- **VS Code**: Modern editor with extensions (recommended)
- **Vim**: Classic Vim setup with vim-plug (reference)
- **Zed**: Modern code editor configuration (alternative)

### 🪟 Desktop & UI

- **Aerospace**: Primary tiling window manager with comprehensive hotkey configuration (macOS)
- **SketchyBar**: Custom menu bar with system monitors (macOS)
- **Borders**: Window border customization (macOS)
- **LinearMouse**: Mouse acceleration customization (macOS)
- **Amethyst**: Alternative tiling window manager (macOS - reference only)

👆 *[Quick setup: Jump to installation guide](#installation)*

### 📦 Package Management

- **Homebrew**: Centralized package management via Brewfile (macOS)
- **Mise**: Development tool version management

### 🤖 AI Tools

- **Claude Code**: MCP servers config (Atlassian, GitHub, Figma, Azure, Playwright, Context7, Crowdin, and more) + Caveman plugin

### 🔧 Additional Tools

- **Git**: Portable gitconfig with machine-local identity override pattern
- **K9s**: Kubernetes cluster management
- **SKHD**: Hotkey daemon (unused - Aerospace handles hotkeys)

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
   stow nvim zsh tmux ghostty mise atuin git starship  # Core tools
   stow aerospace sketchybar borders linearmouse  # macOS window management
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
├── aerospace/          # Primary tiling window manager (macOS)
├── alacritty/         # GPU-accelerated terminal emulator (uninstalled, kept for reference)
├── amethyst/          # Alternative tiling window manager (macOS - unused, kept for reference)
├── atuin/             # Shell history manager
├── borders/           # Window border customization
├── brew/              # Package management (mainly for macOS)
│   ├── Brewfile       # All installed packages/apps
│   └── README.md      # Package management guide
├── claude/            # Claude Code AI assistant config
├── git/               # Git config (portable; identity goes in ~/.config/git/config.local)
├── ghostty/           # Terminal emulator
├── k9s/               # Kubernetes cluster manager
├── kitty/             # Terminal emulator
├── linearmouse/       # Mouse settings (macOS)
├── mise/              # Development tool version manager
├── nvim/              # Neovim editor configuration
├── sketchybar/        # Custom menu bar (macOS)
├── skhd/              # Hotkey daemon (macOS - unused, Aerospace handles hotkeys)
├── starship/          # Prompt config (starship, minimal built-in defaults)
├── tmux/              # Terminal multiplexer
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
- **Efficient window management** with Aerospace tiling and hotkeys (macOS)
- **Kubernetes management** with K9s
- **Version management** with Mise

### System Integration

- **Custom menu bar** with SketchyBar showing system stats (macOS)
- **Window borders** for better visual separation (macOS)
- **Comprehensive hotkey management** built into Aerospace (macOS)
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
- Aerospace serves as the primary window manager with integrated hotkey management on macOS
- **Important**: Using Aerospace disables macOS native word navigation (Option+arrow keys) due to hotkey conflicts

## 📚 Useful Commands

```bash
# Reload zsh configuration
source ~/.zshrc

# Restart Aerospace (macOS window manager)
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
