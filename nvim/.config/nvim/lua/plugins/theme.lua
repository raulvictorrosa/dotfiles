---@module "lazy"
---@type LazySpec
return {
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
  },
  {
    "folke/tokyonight.nvim",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "dracula",
      colorscheme = "catppuccin",
    },
  },
}
