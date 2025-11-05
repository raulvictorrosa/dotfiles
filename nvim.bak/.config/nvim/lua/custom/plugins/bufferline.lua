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
          -- mode = 'buffers', -- set to "tabs" to only show tabpages instead
          -- themable = true,
          -- numbers = 'none',
          -- close_command = 'bdelete! %d',
          -- right_mouse_command = 'bdelete! %d',
          -- left_mouse_command = 'buffer %d',
          middle_mouse_command = 'bdelete! %d',

          -- indicator = {
          --   icon = '▎',
          --   style = 'icon',
          -- },
          -- buffer_close_icon = '',
          -- modified_icon = '●',
          -- close_icon = '',
          -- left_trunc_marker = '',
          -- right_trunc_marker = '',
          -- name_formatter = function(buf)
          --   return buf.name
          -- end,
          -- max_name_length = 18,
          -- max_prefix_length = 15,
          -- truncate_names = true,
          tab_size = 21,
          diagnostics = 'nvim_lsp',
          -- diagnostics_update_in_insert = false,
          offsets = {
            {
              filetype = 'neo-tree',
              text = 'Explorer',
              text_align = 'left',
              -- separator = true,
              highlight = 'Directory',
            },
          },
          -- color_icons = true,
          -- show_buffer_icons = true,
          -- show_buffer_close_icons = true,
          -- show_close_icon = true,
          -- show_tab_indicators = true,
          -- persist_buffer_sort = true,
          -- separator_style = 'thick',
          -- enforce_regular_tabs = false,
          -- always_show_bufferline = true,
          -- sort_by = 'id',
        },
      }
    end,
  },
}
