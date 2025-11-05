-- VSCode-specific configurations
-- This file contains all VSCode integration settings and keymaps

setupVsCodeConfigs = function()
  if not vim.g.vscode then
    return -- Only run when in VSCode
  end

  -- Disable statusline in VSCode since VSCode has its own status bar
  vim.o.showmode = true
  vim.o.laststatus = 0

  local vscode = require 'vscode'
  -- Remap folding keys to use VSCode commands
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }
  keymap('n', 'zM', function()
    vscode.call 'editor.foldAll'
  end, opts)
  keymap('n', 'zR', function()
    vscode.call 'editor.unfoldAll'
  end, opts)
  keymap('n', 'zc', function()
    vscode.call 'editor.fold'
  end, opts)
  keymap('n', 'zC', function()
    vscode.call 'editor.foldRecursively'
  end, opts)
  keymap('n', 'zo', function()
    vscode.call 'editor.unfold'
  end, opts)
  keymap('n', 'zO', function()
    vscode.call 'editor.unfoldRecursively'
  end, opts)
  keymap('n', 'za', function()
    vscode.call 'editor.toggleFold'
  end, opts)

  -- Additional VSCode-specific keymaps (with absolute priority - will override telescope and other plugins)
  local function set_vscode_keymap(mode, lhs, rhs, opts)
    -- Force override any existing keymap
    vim.keymap.del(mode, lhs, { silent = true })
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- Use vim.schedule to ensure these keymaps are set after all plugins have loaded
  vim.schedule(function()
    -- Safely try to delete existing keymaps and set new ones
    pcall(set_vscode_keymap, 'n', '<leader>sf', function()
      vscode.call 'workbench.action.quickOpen'
    end, { desc = 'Quick Open', noremap = true, silent = true })

    pcall(set_vscode_keymap, 'n', '<leader>sg', function()
      vscode.call 'workbench.view.search'
    end, { desc = 'Search in files', noremap = true, silent = true })

    pcall(set_vscode_keymap, 'n', '<leader><space>', function()
      vscode.call 'workbench.action.showAllEditors'
    end, { desc = 'Show all buffers', noremap = true, silent = true })

    pcall(set_vscode_keymap, 'n', '<leader>ss', function()
      vscode.call 'workbench.action.showCommands'
    end, { desc = 'Command palette', noremap = true, silent = true })

    pcall(set_vscode_keymap, 'n', '<leader>sk', function()
      vscode.call 'workbench.action.openGlobalKeybindings'
    end, { desc = 'Open Global Keybindings', noremap = true, silent = true })

    -- Uncomment and modify this if you want to override telescope's file search
  end)
end

setupVsCodeConfigs()
