if require("util").in_vscode() then
  return
end
local now = MiniDeps.now
now(function()
  require("mini.colors").setup()
  vim.cmd.colorscheme("wenvim-dark")
end)
