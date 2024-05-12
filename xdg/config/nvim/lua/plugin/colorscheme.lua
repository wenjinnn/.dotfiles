local not_vscode = require("util").not_vscode
return {
  {
    "Mofiqul/vscode.nvim",
    cond = not_vscode,
    priority = 1000,
    opts = function()
      local c = require("vscode.colors").get_colors()
      return {
        transparent = true,
        group_overrides = {
          -- this supports the same val table as vim.api.nvim_set_hl
          -- use colors from this colorscheme by requiring vscode.colors!
          TelescopePromptNormal = { link = "Pmenu" },
          TelescopeResultsNormal = { link = "Pmenu" },
          TelescopePreviewNormal = { fg = c.vscFront, bg = c.vscBack },
          TelescopePreviewBorder = { fg = c.vscFront, bg = c.vscBack },
          TelescopeResultsBorder = { link = "Pmenu" },
          TelescopePromptBorder = { link = "Pmenu" },
          TelescopePromptTitle = { link = "lualine_a_insert" },
          TelescopeResultsTitle = { link = "lualine_a_normal" },
          TelescopePreviewTitle = { link = "lualine_a_normal" },
          ["@interface"] = { link = "@constant" },
          ["@lsp.type.interface"] = { link = "@interface" },
          CmpItemMenu = { link = "Comment" },
        },
      }
    end,
  },
}
