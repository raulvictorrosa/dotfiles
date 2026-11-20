-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

if vim.g.vscode then
  vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
end

-- Sessions saved after `nvim <dir>` keep that directory in the arglist, so a restored
-- session gets an extra listed buffer named after the folder. Selecting it makes snacks'
-- netrw replacement open the explorer and delete the buffer, so it just "vanishes".
-- Drop the directory from the arglist and wipe that buffer when a session is loaded
-- (also cleans up sessions that were saved before this).
vim.api.nvim_create_autocmd("SessionLoadPost", {
  group = vim.api.nvim_create_augroup("user_session_drop_dir_buffer", { clear = true }),
  callback = function()
    vim.cmd("silent! %argdelete")
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.fn.isdirectory(name) == 1 and #vim.fn.win_findbuf(buf) == 0 then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end,
})
