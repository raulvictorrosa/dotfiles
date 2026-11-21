---@module "lazy"
---@type LazySpec
return {
  -- Install all theme plugins (lazy-loaded) but don't apply them.
  -- This keeps every colorscheme available to `:colorscheme` and the colorscheme
  -- picker (<leader>uC); the one used at startup is set in theme.lua.
  {
    "ribru17/bamboo.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "bjarneo/aether.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "bjarneo/ethereal.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "bjarneo/hackerman.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "sainnhe/everforest",
    lazy = true,
    priority = 1000,
  },
  {
    "kepano/flexoki-neovim",
    lazy = true,
    priority = 1000,
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "tahayvr/matteblack.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "loctvl842/monokai-pro.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "shaunsingh/nord.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    priority = 1000,
  },
}
