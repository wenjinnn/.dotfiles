local add, later = MiniDeps.add, MiniDeps.later

later(function()
  local map = require('wenvim.util').map
  vim.g.neoterm_automap_keys = '<leader>tt'
  add('kassio/neoterm')
  add('tpope/vim-dispatch')
  add('vim-test/vim-test')
  vim.g['test#strategy'] = 'dispatch'
  vim.g.dispatch_no_tmux_make = 1
  map('n', '<leader>tn', '<cmd>TestNearest<CR>', 'Run nearest test')
  map('n', '<leader>tf', '<cmd>TestFile<CR>', 'Run file tests')
  map('n', '<leader>ts', '<cmd>TestSuite<CR>', 'Run test suite')
  map('n', '<leader>tl', '<cmd>TestLast<CR>', 'Run last test')
  map('n', '<leader>tv', '<cmd>TestVisit<CR>', 'Visit test file')
end)
