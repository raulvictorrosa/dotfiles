-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- vim.g.vscode is only set when this config runs inside VS Code's vscode-neovim extension.
-- There, LazyVim's `lazyvim_wrap_spell` autocmds (which turn on wrap + spell for text
-- filetypes like markdown and gitcommit) are removed, because VS Code does its own
-- spell checking (cSpell) and word wrap. In a normal terminal nvim this block does nothing.
if vim.g.vscode then
  vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
end

-- Session restore fixes (directory buffer, explorer sidebar): see config/session.lua
require("config.session")
