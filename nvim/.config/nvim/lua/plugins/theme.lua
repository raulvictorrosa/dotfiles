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
      -- "catppuccin-nvim", not "catppuccin": Neovim 0.12 ships its own built-in "catppuccin"
      -- colorscheme, which wins at startup and leaves FloatBorder/NormalFloat on Neovim defaults.
      colorscheme = "catppuccin-nvim",
    },
  },
}
