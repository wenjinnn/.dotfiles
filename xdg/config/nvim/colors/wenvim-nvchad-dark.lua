-- Default NvChad Dark colorscheme using mini.base16
-- Based on NvChad/base46 default-dark
local palette = {
  base00 = '#181818', -- bg
  base01 = '#282828',
  base02 = '#383838',
  base03 = '#585858',
  base04 = '#b8b8b8',
  base05 = '#d8d8d8',
  base06 = '#e8e8e8',
  base07 = '#f8f8f8', -- fg
  base08 = '#ab4642', -- red
  base09 = '#dc9656', -- orange
  base0A = '#f7ca88', -- yellow
  base0B = '#a1b56c', -- green
  base0C = '#86c1b9', -- cyan
  base0D = '#7cafc2', -- blue
  base0E = '#ba8baf', -- purple
  base0F = '#a16946', -- brown
}
require('mini.base16').setup({ palette = palette })
wenvim.color.setup_wenvim_color({ background = palette.base00, foreground = palette.base07 })
