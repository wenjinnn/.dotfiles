local add, later = MiniDeps.add, MiniDeps.later
local map = require('wenvim.util').map

-- git
later(function()
  add('tpope/vim-fugitive')
  vim.g.fugitive_summary_format = '%ch | %an | %s'
  require('mini.diff').setup()
  map('n', '<leader>go', MiniDiff.toggle_overlay, 'Git toggle overlay')
end)
