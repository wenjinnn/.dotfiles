-- Gruvchad colorscheme using mini.base16
-- Based on NvChad/base46 gruvchad (modified gruvbox-material)
local palette = {
  base00 = '#1e2122', -- bg
  base01 = '#2c2f30',
  base02 = '#36393a',
  base03 = '#404344',
  base04 = '#d4be98',
  base05 = '#c0b196',
  base06 = '#c3b499',
  base07 = '#c7b89d', -- fg
  base08 = '#ec6b64', -- red
  base09 = '#e78a4e', -- orange
  base0A = '#e0c080', -- yellow
  base0B = '#a9b665', -- green
  base0C = '#86b17f', -- aqua
  base0D = '#7daea3', -- blue
  base0E = '#d3869b', -- purple
  base0F = '#d65d0e', -- brown
}
require('mini.base16').setup({ palette = palette })
wenvim.color.setup_wenvim_color({ background = palette.base00, foreground = palette.base07 })
