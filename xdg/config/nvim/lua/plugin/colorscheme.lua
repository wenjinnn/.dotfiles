local not_vscode = require("util").not_vscode
return {
  {
    "catppuccin/nvim",
    cond = not_vscode,
    name = "catppuccin",
    priority = 1000,
    opts = {
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
    },
    init = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
