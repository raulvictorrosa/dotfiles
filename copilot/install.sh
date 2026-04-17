#!/usr/bin/env bash
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install Copilot plugins (list is hardcoded below)
echo "Installing Copilot plugins..."
for plugin in awesome-copilot azure-cloud-development doublecheck frontend-web-dev \
              gem-team java-development react19-upgrade security-best-practices \
              software-engineering-team testing-automation typescript-mcp-development; do
  copilot plugin install "${plugin}@awesome-copilot"
done

# Copy manually-tracked skills (dir is gitignored; skip if absent)
echo "Copying manual skills..."
if [ -d "$DOTFILES_DIR/.agents/skills" ] && [ -n "$(ls -A "$DOTFILES_DIR/.agents/skills" 2>/dev/null)" ]; then
    mkdir -p ~/.agents/skills
    cp -r "$DOTFILES_DIR/.agents/skills/." ~/.agents/skills/
fi

# Copy hooks
echo "Copying hooks..."
mkdir -p ~/.agents/hooks/scripts
cp "$DOTFILES_DIR/.agents/hooks/hooks.json" ~/.agents/hooks/
cp "$DOTFILES_DIR/.agents/hooks/scripts/." ~/.agents/hooks/scripts/

# Copy VS Code agents
echo "Copying VS Code agents..."
mkdir -p ~/Library/Application\ Support/Code/User/agents
cp "$DOTFILES_DIR/vscode-agents/." ~/Library/Application\ Support/Code/User/agents/

# Copy VS Code instructions
echo "Copying VS Code instructions..."
mkdir -p ~/Library/Application\ Support/Code/User/instructions
cp "$DOTFILES_DIR/vscode-instructions/." ~/Library/Application\ Support/Code/User/instructions/

echo "Done!"
