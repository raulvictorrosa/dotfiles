-- Dracula Theme

return {
  {
    'dracula/vim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      vim.cmd.colorscheme 'dracula'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 e
