if vim.g.vscode then return end

local add, later = MiniDeps.add, MiniDeps.later
local map = require('wenvim.util').map
local augroup = require('wenvim.util').augroup
local util_lsp = require('wenvim.util.lsp')

-- Lspconfig related
later(function()
  add({
    source = 'neovim/nvim-lspconfig',
    depends = {
      'b0o/SchemaStore.nvim',
      'mfussenegger/nvim-jdtls',
      'https://gitlab.com/schrieveslaach/sonarlint.nvim',
    },
  })
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
  })
  vim.api.nvim_create_autocmd('LspAttach', {
    group = augroup('lsp_attach'),
    callback = util_lsp.on_attach,
  })
  vim.api.nvim_create_autocmd('LspDetach', {
    group = augroup('lsp_detach'),
    callback = util_lsp.on_detach,
  })
  -- if didn't have this env, don't enable sonarlint LSP
  local sonarlint_path = os.getenv('SONARLINT_PATH')
  if sonarlint_path ~= nil then
    require('sonarlint').setup({
      server = {
        cmd = {
          util_lsp.get_java_cmd(),
          '-jar',
          sonarlint_path .. '/server/sonarlint-ls.jar',
          -- Ensure that sonarlint-language-server uses stdio channel
          '-stdio',
          '-analyzers',
          -- paths to the analyzers you need, using those for python and java in this example
          sonarlint_path .. '/analyzers/sonarpython.jar',
          sonarlint_path .. '/analyzers/sonarcfamily.jar',
          sonarlint_path .. '/analyzers/sonarjava.jar',
          sonarlint_path .. '/analyzers/sonarjs.jar',
          sonarlint_path .. '/analyzers/sonarxml.jar',
          sonarlint_path .. '/analyzers/sonarhtml.jar',
          sonarlint_path .. '/analyzers/sonargo.jar',
        },
      },
      filetypes = {
        'python',
        'cpp',
        'java',
        'javascript',
        'typescript',
        'xml',
        'go',
      },
    })
  end
  -- finally, some LSP related keymaps
  local function inlay_hint_toggle()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
  end
  local function list_workspace_folders() vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders())) end
  map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Lsp code action')
  map('n', '<leader>k', vim.lsp.buf.signature_help, 'Lsp signature help')
  map('n', '<leader>cw', vim.lsp.buf.add_workspace_folder, 'Lsp add workspace folder')
  map('n', '<leader>cW', vim.lsp.buf.remove_workspace_folder, 'Lsp remove workspace folder')
  map('n', '<leader>cR', vim.lsp.buf.rename, 'Lsp rename')
  map('n', '<leader>cl', vim.diagnostic.setloclist, 'Lsp diagnostic location list')
  map('n', '<leader>cI', vim.lsp.buf.incoming_calls, 'Lsp incoming calls')
  map('n', '<leader>ch', vim.lsp.buf.outgoing_calls, 'Lsp outgoing calls')
  map('n', '<leader>cH', inlay_hint_toggle, 'Lsp inlay hint toggle')
  map('n', '<leader>cL', list_workspace_folders, 'Lsp list workspace folder')
end)
