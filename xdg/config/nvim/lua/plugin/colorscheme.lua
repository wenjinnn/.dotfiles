local in_vscode = require("util").in_vscode
if in_vscode() then
  return
end
local now = MiniDeps.now
now(function()
  require("mini.colors").setup()
  require("mini.hues").setup({
    background = "#1e2131",
    foreground = "#c4c6cd",
  })
  vim.api.nvim_set_hl(0, "@lsp.type.interface", { link = "@interface" })
  vim.api.nvim_set_hl(0, "@interface", { link = "@constant" })
  local visual = vim.api.nvim_get_hl(0, { name = "Visual" })
  visual.bold = true
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.api.nvim_set_hl(0, "Visual", visual)
end)
