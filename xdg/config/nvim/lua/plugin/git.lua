local add, later = MiniDeps.add, MiniDeps.later
local map = require('util').map

-- git
later(function()
  add('tpope/vim-fugitive')
end)

later(function()
  require('mini.diff').setup()
  map('n', '<leader>go', MiniDiff.toggle_overlay, 'Git toggle overlay')
end)
