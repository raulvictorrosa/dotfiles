---@module "lazy"
---@module "bufferline"
---@type LazySpec
return {
  "akinsho/bufferline.nvim",
  -- Runs at startup, before bufferline itself loads (VeryLazy), so the start screen never gets a bar.
  init = function()
    -- Bufferline only offers "always" or "from two buffers on". Show it as soon as one real file
    -- is open instead, and keep the top row free on the dashboard / empty start (a small window
    -- would otherwise lose a line to an empty bar).
    local function update()
      local has_file = vim.iter(vim.api.nvim_list_bufs()):any(function(buf)
        return vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
      end)
      vim.o.showtabline = has_file and 2 or 0
    end
    vim.api.nvim_create_autocmd({ "VimEnter", "BufAdd", "BufEnter", "BufDelete", "BufWipeout" }, {
      callback = function()
        vim.schedule(update) -- after the buffer list has changed
      end,
    })
  end,
  ---@type bufferline.UserConfig
  opts = {
    options = {
      auto_toggle_bufferline = false, -- visibility is handled by the autocmd in `init`
    },
  },
}
