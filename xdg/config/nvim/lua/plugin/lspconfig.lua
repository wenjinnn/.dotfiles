if vim.g.vscode then return end

local add, later = MiniDeps.add, MiniDeps.later
local map = require('util').map

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
    'eslint',
    'jsonls',
    'lua_ls',
    'vue_ls',
    'ts_ls',
    'yamlls',
    'nixd',
    'pylsp',
    'texlab',
    'bashls',
    'cssls',
    'html',
    'lemminx',
    'vale_ls',
    'vimls',
    'clangd',
    'taplo',
    'rust_analyzer',
    'gopls',
  })
  -- custom jdtls setup
  require('lsp.jdtls').setup()
  -- if didn't have this env, don't enable sonarlint LSP
  local util = require('util.lsp')
  local sonarlint_path = os.getenv('SONARLINT_PATH')
  if sonarlint_path ~= nil then
    require('sonarlint').setup({
      server = {
        cmd = {
          util.get_java_cmd(),
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
