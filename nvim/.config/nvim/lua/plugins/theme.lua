return {
  -- Both Dracula plugins ship a colorscheme called "dracula", so they clash.
  -- Each one gets its own name through an alias in `colors/`:
  --   :colorscheme dracula-official  -> dracula/vim (official, Vimscript)
  --   :colorscheme dracula-nvim      -> Mofiqul/dracula.nvim (community, Lua, Treesitter/LSP)
  {
    "dracula/vim",
    name = "dracula-official",
    lazy = true,
    priority = 1000,
  },
  {
    "Mofiqul/dracula.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "dracula-official",
      colorscheme = "catppuccin",
    },
  },
}
