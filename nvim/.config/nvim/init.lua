-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Session restore fixes (directory buffer, explorer sidebar). Loaded here, not from
-- config/autocmds.lua, so they are active before a session is restored at startup.
require("config.session")
