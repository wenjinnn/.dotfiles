-- my nvim config write in lua
vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local lockpath = os.getenv('LAZY_NVIM_LOCK_PATH')
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
local lazy_config = {
    dev = {
      path = '~/project/my'
    }
}
if lockpath then
  lazy_config.lockfile = lockpath .. '/lazy-lock.json'
end
require('lazy').setup('plugin', lazy_config)
