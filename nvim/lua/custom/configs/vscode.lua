-- VSCode-specific configurations
-- This file contains all VSCode integration settings and keymaps

setupVsCodeConfigs = function()
  if not vim.g.vscode then
    return -- Only run when in VSCode
  end
  local vscode = require('vscode')
  -- Remap folding keys to use VSCode commands
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }
  keymap('n', 'zM', function()
    vscode.call("editor.foldAll")
  end, opts)
  keymap('n', 'zR', function()
    vscode.call("editor.unfoldAll")
  end, opts)
  keymap('n', 'zc', function()
    vscode.call("editor.fold")
  end, opts)
  keymap('n', 'zC', function()
    vscode.call("editor.foldRecursively")
  end, opts)
  keymap('n', 'zo', function()
    vscode.call("editor.unfold")
  end, opts)
  keymap('n', 'zO', function()
    vscode.call("editor.unfoldRecursively")
  end, opts)
  keymap('n', 'za', function()
    vscode.call("editor.toggleFold")
  end, opts)
end

setupVsCodeConfigs()
