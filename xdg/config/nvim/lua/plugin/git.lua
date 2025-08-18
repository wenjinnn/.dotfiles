local add, later = MiniDeps.add, MiniDeps.later
local map = require('util').map

-- git
later(function()
  add({
    source = 'tpope/vim-fugitive',
    depends = { 'rbong/vim-flog' },
  })
  require('mini.diff').setup()
  map('n', '<leader>go', MiniDiff.toggle_overlay, 'Git toggle overlay')
end)
