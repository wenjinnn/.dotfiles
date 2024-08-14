vim.api.nvim_set_hl(0, "@lsp.type.interface", { link = "@interface" })
vim.api.nvim_set_hl(0, "@interface", { link = "@constant" })
local visual = vim.api.nvim_get_hl(0, { name = "Visual" })
visual.bold = true
---@diagnostic disable-next-line: param-type-mismatch
vim.api.nvim_set_hl(0, "Visual", visual)

local base_color = {
  background = "#1e2131",
  foreground = "#c4c6cd",
}
require("mini.hues").setup(base_color)
local palette = require("mini.hues").make_palette(base_color)
vim.g.terminal_color_8 = palette.bg_mid2
vim.g.terminal_color_9 = palette.red_mid2
vim.g.terminal_color_10 = palette.green_mid2
vim.g.terminal_color_11 = palette.yellow_mid2
vim.g.terminal_color_12 = palette.azure_mid2
vim.g.terminal_color_13 = palette.purple_mid2
vim.g.terminal_color_14 = palette.cyan_mid2
vim.g.terminal_color_15 = palette.fg_mid2
vim.g.colors_name = "wenvim-blue"
