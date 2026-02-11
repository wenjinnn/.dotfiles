local util = require('wenvim.util')
local map = util.map
local gh = util.gh
vim.g.neoterm_automap_keys = '<leader>tt'
vim.pack.add({ gh('kassio/neoterm'), gh('tpope/vim-dispatch'), gh('vim-test/vim-test') })
vim.g['test#strategy'] = 'dispatch'
vim.g.dispatch_no_tmux_make = 1
map('n', '<leader>tt', '<cmd>call neoterm#map_do()<CR>', 'Neoterm tmap do')
map('n', '<leader>tn', '<cmd>TestNearest<CR>', 'Run nearest test')
map('n', '<leader>tf', '<cmd>TestFile<CR>', 'Run file tests')
map('n', '<leader>ts', '<cmd>TestSuite<CR>', 'Run test suite')
map('n', '<leader>tl', '<cmd>TestLast<CR>', 'Run last test')
map('n', '<leader>tv', '<cmd>TestVisit<CR>', 'Visit test file')
