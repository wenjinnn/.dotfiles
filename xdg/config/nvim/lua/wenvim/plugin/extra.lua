if vim.g.vscode then return end

local util = require('wenvim.util')
local map = util.map
local gh = util.gh
local later = util.later
later(function()
  -- ascii draw in neovim
  vim.pack.add({ gh('jbyuki/venn.nvim') })
  map('v', '<leader>vv', ':VBox<cr>', 'Draw a single line box or arrow')
  map('v', '<leader>vd', ':VBoxD<cr>', 'Draw a double line box or arrow')
  map('v', '<leader>vh', ':VBoxH<cr>', 'Draw a heavy line box or arrow')
  map('v', '<leader>vo', ':VBoxO<cr>', 'Draw over a existing box or arrow')
  map('v', '<leader>vO', ':VBoxDO<cr>', 'Draw over a doulbe line on a existing box or arrow')
  map('v', '<leader>vH', ':VBoxHO<cr>', 'Draw over a heavy line on a existing box or arrow')
  map('v', '<leader>vf', ':VFill<cr>', 'Draw fill a area with a solid color')

  -- curl client in neovim
  vim.pack.add({ gh('oysandvik94/curl.nvim') })
  require('curl').setup()

  -- markdown, html, asciidoc, svg preview in browser
  vim.pack.add({ gh('barrettruth/preview.nvim') })
  vim.g.preview = {
    markdown = {
      extra_args = { '-F', 'mermaid-filter' },
      output = function(ctx) return '/tmp/' .. vim.fn.fnamemodify(ctx.file, ':t:r') .. '.html' end,
    },
  }

  -- db manage
  vim.pack.add({ gh('tpope/vim-dadbod'), gh('kristijanhusak/vim-dadbod-completion') })
  vim.api.nvim_create_autocmd('FileType', {
    group = require('wenvim.util').augroup('dadbod'),
    pattern = 'sql',
    callback = function(ev)
      vim.bo[ev.buf].omnifunc = 'vim_dadbod_completion#omni'
      map({ 'n', 'x' }, '<CR>', 'db#op_exec()', { expr = true, desc = 'DB exec current query' })
    end,
  })

  -- AI assistant
  vim.pack.add({ gh('olimorris/codecompanion.nvim'), gh('ravitemer/codecompanion-history.nvim') })
  require('codecompanion').setup({
    extensions = { history = { enabled = true } },
  })
  map({ 'n', 'v' }, '<leader>Ca', '<cmd>CodeCompanionActions<cr>', 'Open Code Companion actions menu')
  map({ 'n', 'v' }, '<leader>CC', '<cmd>CodeCompanionChat Toggle<cr>', 'Toggle Code Companion chat window')
  map('v', '<leader>Ca', '<cmd>CodeCompanionChat Add<cr>', 'Add selection to Code Companion chat context')

  -- Expand 'cc' into 'CodeCompanion' in the command line
  vim.cmd([[cab cc CodeCompanion]])
end)
