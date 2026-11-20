-- Alias for the official Dracula theme (dracula/vim), whose own colorscheme
-- name ("dracula") collides with the community Mofiqul/dracula.nvim.
require("lazy").load({ plugins = { "dracula-official" } })
vim.cmd.source(vim.fn.stdpath("data") .. "/lazy/dracula-official/colors/dracula.vim")
vim.g.colors_name = "dracula-official"
