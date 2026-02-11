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

-- curl client in neovim
now(function()
  add({ source = 'oysandvik94/curl.nvim', depends = { 'nvim-lua/plenary.nvim' } })
  local curl = require('curl')
  curl.setup()
  map('n', '<leader>Cc', curl.open_curl_tab, 'Open a curl tab scoped to current CWD')
  map('n', '<leader>Co', curl.open_global_tab, 'Open a curl tab with global scope')
  map('n', '<leader>Ca', curl.create_scoped_collection, 'Create or open a collection scoped to current CWD')
  map('n', '<leader>CA', curl.create_global_collection, 'Create or open a collection with global scope')
  map('n', '<leader>CC', curl.pick_scoped_collection, 'Pick a scoped collection')
  map('n', '<leader>CO', curl.pick_global_collection, 'Pick a global collection')
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
