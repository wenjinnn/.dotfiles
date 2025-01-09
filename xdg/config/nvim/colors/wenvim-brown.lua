---@diagnostic disable: param-type-mismatch
local base_color = {
  background = "#1d2021",
  foreground = "#fbf1c7",
  saturation = "high",
}
require("mini.hues").setup(base_color)
require("util.color").setup_wenvim_color(base_color)

vim.g.colors_name = "wenvim-blue"
