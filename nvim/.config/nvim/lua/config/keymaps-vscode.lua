-- VSCode-specific configuration. Only runs inside the vscode-neovim extension.
if not vim.g.vscode then
  return
end

vim.o.showmode = true
