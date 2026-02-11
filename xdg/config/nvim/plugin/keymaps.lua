-- The keymaps here are independent of plugins
-- all the keymap that related to plugin it self are declared after plugin
vim.schedule(function()
  local util = require('wenvim.util')
  local map = util.map
  map('n', '<leader>S', '<cmd>windo set scrollbind!<CR>', 'Scroll all buffer')
  map('n', '<leader>O', '<cmd>only<CR>', 'Only')
  map('n', '<leader>Q', util.toggle_qf, 'Toggle quickfix list')
  map('n', '<leader>L', util.toggle_loc, 'Toggle location list')
  map('n', '<leader>X', util.toggle_win_diff, 'Diffthis windowed buffers')
  map('n', '<leader>R', util.source_all, 'Resource all config')
  map('n', '<leader>U', vim.pack.update, 'Update plugins')

  -- copy/paste to system clipboard
  map({ 'n', 'v' }, '<leader>y', '"+y', 'Yank to system clipboard')
  map('n', '<leader>Y', '"+Y', 'Yank line to system clipboard')
  map({ 'n', 'v' }, '<leader>0', '"0p', 'Paste from last yank')
  map('n', '<leader>p', '"+p', 'Paste from system clipboard')

  --keywordprg
  map('n', '<leader>K', '<cmd>norm! K<cr>', 'Keywordprg')
  map('n', '<leader>]', '<cmd>!ctags<cr>', 'Ctags')
  map('n', '[g', '<cmd>colder<cr>', 'Go to older quickfix list')
  map('n', ']g', '<cmd>cnewer<cr>', 'Go to newer quickfix list')
  map('n', '[n', '<cmd>lolder<cr>', 'Go to older location list')
  map('n', ']n', '<cmd>lnewer<cr>', 'Go to newer location list')
end)
