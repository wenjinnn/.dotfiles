local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
  require('mini.misc').setup()
  MiniMisc.setup_auto_root()
  MiniMisc.setup_termbg_sync()
  MiniMisc.setup_restore_cursor()
  local use_nested_comments = function() MiniMisc.use_nested_comments() end
  vim.api.nvim_create_autocmd('BufEnter', {
    group = require('wenvim.util').augroup('nested_comments'),
    callback = use_nested_comments
  })
  require('wenvim.util').map('n', '<leader>z', '<cmd>lua MiniMisc.zoom()<cr>', 'Zoom current window')
end)

later(function() require('mini.extra').setup() end)

later(function()
  require('mini.basics').setup({
    extra_ui = true,
    mappings = { windows = false },
  })
  -- disable mini.basics C-s mapping
  vim.keymap.del({ 'n', 'i', 'x' }, '<C-s>')
end)
