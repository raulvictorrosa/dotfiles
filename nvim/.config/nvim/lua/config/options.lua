-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.winborder = "rounded"
opt.spelllang = { "en", "pt" }
-- vim.opt.statuscolumn = ""
opt.colorcolumn = "80,100,120"

-- No installed plugin needs the node/perl/ruby/python3 remote plugin hosts.
-- node/python/ruby here come from mise's floating "latest" version, so a
-- `npm install -g neovim` (etc.) would silently vanish on the next runtime
-- bump anyway — disable the providers instead of chasing that.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
