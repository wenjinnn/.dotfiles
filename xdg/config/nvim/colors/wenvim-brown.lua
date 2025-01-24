---@diagnostic disable: param-type-mismatch
local base_color = {
  background = "#202020",
  foreground = "#ddc7a1",
  saturation = "mediumhigh",
}
require("mini.hues").setup(base_color)
require("util.color").setup_wenvim_color(base_color)

vim.g.colors_name = "wenvim-blue"
