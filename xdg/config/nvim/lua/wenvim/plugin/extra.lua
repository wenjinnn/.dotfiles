if vim.g.vscode then return end

local map = require('wenvim.util').map
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
  -- ascii draw in neovim
  add('jbyuki/venn.nvim')
  map('v', '<leader>vv', ':VBox<cr>', 'Draw a single line box or arrow')
  map('v', '<leader>vd', ':VBoxD<cr>', 'Draw a double line box or arrow')
  map('v', '<leader>vh', ':VBoxH<cr>', 'Draw a heavy line box or arrow')
  map('v', '<leader>vo', ':VBoxO<cr>', 'Draw over a existing box or arrow')
  map('v', '<leader>vO', ':VBoxDO<cr>', 'Draw over a doulbe line on a existing box or arrow')
  map('v', '<leader>vH', ':VBoxHO<cr>', 'Draw over a heavy line on a existing box or arrow')
  map('v', '<leader>vf', ':VFill<cr>', 'Draw fill a area with a solid color')
end)

-- http client
later(function()
  add('mistweaverco/kulala.nvim')
  local kulala = require('kulala')
  kulala.setup({ display_mode = 'float' })
  map({ 'n', 'v' }, '<leader>re', kulala.run, 'Execute request')
  map({ 'n', 'v' }, '<leader>ra', kulala.run_all, 'Execute all request')
  map('n', '<leader>rA', require('kulala.ui.auth_manager').open_auth_config, 'Open auth config')
  map('n', '<leader>ro', kulala.open, 'Open kulala')
  map('n', '<leader>rg', kulala.download_graphql_schema, 'Download graphql schema')
  map('n', '<leader>rx', kulala.scripts_clear_global, 'Scripts clear global')
  map('n', '<leader>rX', kulala.clear_cached_files, 'Scripts clear cached files')
  map('n', '<leader>rr', kulala.replay, 'Replay last run request')
  map('n', '<leader>rt', kulala.show_stats, 'Shows statistics of last request')
  map('n', '<leader>rp', kulala.scratchpad, 'Opens scratchpad')
  map('n', '<leader>rC', kulala.close, 'Close kulala')
  map('n', '<leader>ri', kulala.inspect, 'Inspect current request')
  map('n', '<leader>rv', kulala.toggle_view, 'Toggle between body and headers')
  map('n', '<leader>rc', kulala.copy, 'Copy current request as a curl command')
  map('n', '<leader>rf', kulala.search, 'searches for http files')
  map('n', '<leader>rE', kulala.set_selected_env, 'Sets selected environment')
  map('n', '<leader>rF', kulala.from_curl, 'Paste curl from clipboard as http request')
  map('n', '[r', kulala.jump_prev, 'Jump to previous request')
  map('n', ']r', kulala.jump_next, 'Jump to next request')
end)

-- markdown, html, asciidoc, svg preview in browser
later(function()
  add('brianhuster/live-preview.nvim')
  map('n', '<leader>ls', '<cmd>LivePreview start<cr>', 'Live preview start')
  map('n', '<leader>lc', '<cmd>LivePreview close<cr>', 'Live preview close')
  map('n', '<leader>lp', '<cmd>LivePreview pick<cr>', 'Live preview pick')
end)

-- db manage
later(function()
  add({ source = 'tpope/vim-dadbod', depends = { 'kristijanhusak/vim-dadbod-completion' } })
  vim.api.nvim_create_autocmd('FileType', {
    group = require('wenvim.util').augroup('dadbod'),
    pattern = 'sql',
    callback = function(ev)
      vim.bo[ev.buf].omnifunc = 'vim_dadbod_completion#omni'
      map('x', '<leader>rq', 'db#op_exec()', { expr = true, desc = 'DB exec current query' })
    end,
  })
end)
