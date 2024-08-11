local in_vscode = require("util").in_vscode
if in_vscode() then
  return
end
local add, now = MiniDeps.add, MiniDeps.now
now(function()
  add({ source = "catppuccin/nvim" })
  require("catppuccin").setup({
    integrations = {
      native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
      },
  })
  vim.cmd.colorscheme("catppuccin")
end)
