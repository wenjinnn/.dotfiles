---@diagnostic disable: param-type-mismatch
local base_color = {
  background = "#1e1e1e",
  foreground = "#e5e5e5",
  saturation = "high",
}
require("mini.hues").setup(base_color)
require("util.color").setup_wenvim_color(base_color)

vim.g.colors_name = "wenvim-blue"
