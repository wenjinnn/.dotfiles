---@diagnostic disable: param-type-mismatch
local base_color = {
  background = '#1d2021',
  foreground = '#bdae93',
}
require('mini.hues').setup(base_color)
require('util.color').setup_wenvim_color(base_color)
