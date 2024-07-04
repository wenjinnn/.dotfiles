local not_vscode = require("util").not_vscode
return {
  {
    "folke/tokyonight.nvim",
    cond = not_vscode,
    lazy = false,
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("tokyonight")
    end,
    opts = {
      transparent = true, -- Enable this to disable setting the background color
      terminal_colors = false,
      on_colors = function(colors)
        colors.bg_statusline = colors.none
      end,
    },
  },
}
