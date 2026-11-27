---@module "lazy"
---@module "lazyvim"
---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  ---@type PluginLspOpts
  opts = {
    -- Inline type and parameter hints start hidden. Toggle them with <leader>uh (Space u h).
    inlay_hints = { enabled = false },
  },
}
