local add, later = MiniDeps.add, MiniDeps.later

later(function()
  add('kassio/neoterm')
  add('tpope/vim-dispatch')
  add('vim-test/vim-test')
  vim.g['test#strategy'] = 'neoterm'
end)
