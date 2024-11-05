---@diagnostic disable: param-type-mismatch
local base_color = {
  background = "#1f1f1f",
  foreground = "#d4d4d4",
  saturation = "mediumhigh",
}
require("mini.hues").setup(base_color)
require("util.color").setup_terminal_color(base_color)
require("util.color").setup_mini_hues_hl()

vim.g.colors_name = "wenvim-blue"
