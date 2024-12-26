if vim.g.vscode then return end

local now = MiniDeps.now
now(function()
  require("mini.colors").setup()
  vim.cmd.colorscheme("wenvim-dark")
end)
