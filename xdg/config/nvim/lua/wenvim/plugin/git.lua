local add, later = MiniDeps.add, MiniDeps.later
local map = require('wenvim.util').map

-- git
later(function()
  require('mini.git').setup()
  require('mini.diff').setup()
  -- setup vim-fugitive after mini.git so that `:G` `:Git` can override mini.git's
  add('tpope/vim-fugitive')
  vim.g.fugitive_summary_format = '%ch | %an | %s'
  map({ 'n', 'x' }, '<leader>ga', MiniGit.show_at_cursor, 'Git show at cursor')
  map({ 'n', 'v' }, '<leader>gh', MiniGit.show_range_history, 'Git show range history')
  map({ 'n', 'v' }, '<leader>gd', MiniGit.show_diff_source, 'Git show diff source')
  map('n', '<leader>go', MiniDiff.toggle_overlay, 'Git toggle overlay')
end)
