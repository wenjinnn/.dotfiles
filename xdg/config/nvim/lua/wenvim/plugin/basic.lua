local util = require('wenvim.util')
local map = util.map
local gh = util.gh

vim.pack.add({
  gh('nvim-mini/mini.nvim'),
  gh('nvim-lua/plenary.nvim'),
})
require('mini.misc').setup()
MiniMisc.setup_auto_root()
MiniMisc.setup_termbg_sync()
MiniMisc.setup_restore_cursor()
local use_nested_comments = function() MiniMisc.use_nested_comments() end
vim.api.nvim_create_autocmd('BufEnter', {
  group = util.augroup('nested_comments'),
  callback = use_nested_comments,
})
map('n', '<leader>z', '<cmd>lua MiniMisc.zoom()<cr>', 'Zoom current window')

require('mini.basics').setup()
-- disable mini.basics C-s mapping
vim.keymap.del({ 'n', 'i', 'x' }, '<C-S>')
map('i', '<C-S>', vim.lsp.buf.signature_help, 'Show signature help')

require('mini.extra').setup()
