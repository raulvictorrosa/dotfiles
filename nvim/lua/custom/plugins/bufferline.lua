-- Initing bufferline plugin with my config

return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = {
      'nvim-neo-tree/neo-tree.nvim',
      'nvim-tree/nvim-web-devicons' },
    config = function()
      vim.opt.termguicolors = true
      require('bufferline').setup {
        options = {
          middle_mouse_command = 'bdelete! %d',

          tab_size = 21,
          diagnostics = 'nvim_lsp',
          offsets = {
            {
              filetype = 'neo-tree',
              text = 'Explorer',
              text_align = 'left',
              highlight = 'Directory',
            },
          },
        },
      }
    end,
  },
}
