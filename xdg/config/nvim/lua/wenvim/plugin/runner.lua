local add, later = MiniDeps.add, MiniDeps.later

later(function()
  local map = require('wenvim.util').map
  add('kassio/neoterm')
  add('tpope/vim-dispatch')
  add('vim-test/vim-test')
  vim.g['test#strategy'] = 'dispatch'
  map('n', '<leader>tn', '<cmd>TestNearest<CR>', 'Run nearest test')
  map('n', '<leader>tf', '<cmd>TestFile<CR>', 'Run file tests')
  map('n', '<leader>ts', '<cmd>TestSuite<CR>', 'Run test suite')
  map('n', '<leader>tl', '<cmd>TestLast<CR>', 'Run last test')
  map('n', '<leader>tv', '<cmd>TestVisit<CR>', 'Visit test file')
end)
