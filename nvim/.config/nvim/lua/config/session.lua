-- Session restore fixes (persistence.nvim sessions and `:restart`). Loaded from init.lua, NOT
-- from config/autocmds.lua: LazyVim only loads autocmds.lua after startup when nvim is opened
-- without file arguments (plain `nvim`), which is after `:restart` has already restored the
-- session, so the SessionLoadPost autocmd below would be missed.

-- Sessions saved after `nvim <dir>` keep that directory in the arglist, so a restored
-- session gets an extra listed buffer named after the folder. Selecting it makes snacks'
-- netrw replacement open the explorer and delete the buffer, so it just "vanishes".
-- Drop the directory from the arglist and wipe that buffer when a session is loaded
-- (also cleans up sessions that were saved before this).
--
-- The snacks explorer sidebar is a picker window, which sessions do not save either.
-- Keep a flag in an uppercase global (those are stored in sessions, see
-- 'sessionoptions') and reopen the explorer on load when it was open at save time.
-- Sessions saved before this change have no flag, so they restore without explorer.
local session_group = vim.api.nvim_create_augroup("user_session_restore_fixes", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "WinClosed" }, {
  group = session_group,
  callback = function()
    vim.schedule(function()
      vim.g.SnacksExplorerOpen = (_G.Snacks and #Snacks.picker.get({ source = "explorer" }) > 0) and 1 or 0
    end)
  end,
})

-- The session file runs `doautoall SessionLoadPost`, i.e. once per loaded buffer.
local restoring_explorer = false

vim.api.nvim_create_autocmd("SessionLoadPost", {
  group = session_group,
  callback = function()
    vim.cmd("silent! %argdelete")
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.fn.isdirectory(name) == 1 and #vim.fn.win_findbuf(buf) == 0 then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end

    if vim.g.SnacksExplorerOpen == 1 and not restoring_explorer then
      restoring_explorer = true
      local function open_explorer()
        restoring_explorer = false
        if _G.Snacks and #Snacks.picker.get({ source = "explorer" }) == 0 then
          -- focus = false: keep the cursor in the editor window
          Snacks.explorer.open({ focus = false })
        end
      end
      if #vim.api.nvim_list_uis() > 0 then
        vim.schedule(open_explorer)
      else
        -- `:restart` restores the session before the UI attaches again; a picker opened
        -- now would have no screen to draw on, so wait for it.
        vim.api.nvim_create_autocmd("UIEnter", {
          once = true,
          group = session_group,
          callback = function()
            vim.schedule(open_explorer)
          end,
        })
      end
    end
  end,
})
