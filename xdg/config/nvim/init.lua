-- my nvim config write in lua
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Put this at the top of 'init.lua'
local path_package = vim.fn.stdpath('data') .. '/site'
local path_snapshot = vim.fn.stdpath('config') .. '/mini-deps-snap'
local mini_path = path_package .. '/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git',
    'clone',
    '--filter=blob:none',
    -- Uncomment next line to use 'stable' branch
    -- '--branch', 'stable',
    'https://github.com/echasnovski/mini.nvim',
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
end
require('mini.deps').setup({
  path = {
    package = path_package,
    snapshot = path_snapshot,
  },
})
require('plugin').setup()
