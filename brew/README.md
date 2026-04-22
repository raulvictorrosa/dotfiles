# Homebrew Configuration

This directory contains the Homebrew package configuration for your macOS setup.

## Files

- `Brewfile` - Contains all installed Homebrew packages, casks, and VS Code extensions

## Usage

### Install all packages from Brewfile

```bash
cd ~/dotfiles/brew
brew bundle install
```

### Update Brewfile with currently installed packages

```bash
cd ~/dotfiles/brew
brew bundle dump --force
```

### Check which packages would be installed/removed

```bash
cd ~/dotfiles/brew
brew bundle check
```

### Cleanup packages not in Brewfile

```bash
cd ~/dotfiles/brew
brew bundle cleanup
```

## What's Included

- **Taps**: Custom Homebrew repositories
- **Formulae**: Command-line tools and utilities
- **Casks**: macOS applications
- **VS Code Extensions**: All installed VS Code extensions

## Notes

- Run `brew bundle install` on a new machine to replicate your complete setup
- Regularly update the Brewfile with `brew bundle dump --force` to keep it in sync
