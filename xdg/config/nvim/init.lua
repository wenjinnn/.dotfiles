-- my nvim config write in lua
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require('wenvim.plugin').setup()
vim.cmd.colorscheme('wenvim-brown')
