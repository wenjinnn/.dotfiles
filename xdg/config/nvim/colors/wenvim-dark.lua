---@diagnostic disable: param-type-mismatch
local base_color = {
  background = "#1e1e1e",
  foreground = "#e5e5e5",
  saturation = "high",
}
require("mini.hues").setup(base_color)
require("util.color").setup_terminal_color(base_color)
require("util.color").setup_mini_hues_hl()

vim.g.colors_name = "wenvim-blue"
