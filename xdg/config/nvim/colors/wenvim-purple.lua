---@diagnostic disable: param-type-mismatch
local base_color = {
  background = '#1e2131',
  foreground = '#c4c6cd',
}
require('mini.hues').setup(base_color)
require('wenvim.util.color').setup_wenvim_color(base_color)
