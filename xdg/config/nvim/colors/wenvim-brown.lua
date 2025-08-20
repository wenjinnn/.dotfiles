---@diagnostic disable: param-type-mismatch
local base_color = {
  background = '#202020',
  foreground = '#bdae93',
}
require('mini.hues').setup(base_color)
require('wenvim.util.color').setup_wenvim_color(base_color)
