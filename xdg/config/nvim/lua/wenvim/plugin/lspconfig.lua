if vim.g.vscode then return end

local util = require('wenvim.util')
local map = util.map
local gh = util.gh
local augroup = util.augroup
local util_lsp = require('wenvim.util.lsp')

-- Lspconfig related
vim.pack.add({ gh('neovim/nvim-lspconfig'), gh('b0o/SchemaStore.nvim'), gh('mfussenegger/nvim-jdtls') })
vim.lsp.enable({
  'jsonls',
  'jdtls',
  'lua_ls',
  'vtsls',
  'vue_ls',
  'yamlls',
  'nixd',
  'basedpyright',
  'texlab',
  'bashls',
  'cssls',
  'html',
  'lemminx',
  'vimls',
  'clangd',
  'taplo',
  'rust_analyzer',
  'gopls',
  'tinymist',
  'copilot',
})
vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup('lsp_attach'),
  callback = util_lsp.on_attach,
})
vim.api.nvim_create_autocmd('LspDetach', {
  group = augroup('lsp_detach'),
  callback = util_lsp.on_detach,
})
-- finally, some LSP related keymaps
local function inlay_hint_toggle() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end
local function document_color_toggle() vim.lsp.document_color.enable(not vim.lsp.document_color.is_enabled()) end
local function list_workspace_folders() vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders())) end
map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Lsp code action')
map('n', '<leader>k', vim.lsp.buf.signature_help, 'Lsp signature help')
map('n', '<leader>cw', vim.lsp.buf.add_workspace_folder, 'Lsp add workspace folder')
map('n', '<leader>cW', vim.lsp.buf.remove_workspace_folder, 'Lsp remove workspace folder')
map('n', '<leader>cR', vim.lsp.buf.rename, 'Lsp rename')
map('n', '<leader>cl', vim.diagnostic.setloclist, 'Lsp diagnostic location list')
map('n', '<leader>cI', vim.lsp.buf.incoming_calls, 'Lsp incoming calls')
map('n', '<leader>cO', vim.lsp.buf.outgoing_calls, 'Lsp outgoing calls')
map('n', '<leader>cH', inlay_hint_toggle, 'Lsp inlay hint toggle')
map('n', '<leader>ch', document_color_toggle, 'Lsp document color toggle')
map('n', '<leader>cL', list_workspace_folders, 'Lsp list workspace folder')
