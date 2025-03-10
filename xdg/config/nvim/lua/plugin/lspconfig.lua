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
      'JavaHello/spring-boot.nvim',
      'JavaHello/java-deps.nvim',
    },
  })
  local lsp = require('lsp')
  local util = require('util.lsp')
  -- Cuz every LSP could have some custom settings, put those code in here could be very messy
  -- So we define the configuration for each LSP separately and collect in here ../lsp/init.lua,
  -- and follow a specific:
  -- if there is a setup function in LSP custom config, it means that LSP
  -- do all setup work on it self (e.g. jdtls), so we just call the setup function here
  -- if not, modules should exports a table that will pass to nvim-lspconfig setup
  for server_name, config in pairs(lsp) do
    if config.setup ~= nil and type(config.setup) == 'function' then
      config.setup()
    else
      local final_config = util.make_lspconfig(config)
      require('lspconfig')[server_name].setup(final_config)
    end
  end
  -- if didn't have this env, don't enable sonarlint LSP
  local sonarlint_path = os.getenv('SONARLINT_PATH')
  if sonarlint_path ~= nil then
    require('sonarlint').setup({
      server = {
        cmd = {
          'java',
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
        settings = require('lsp.sonarlint-language-server').settings,
        -- limit the interval of sonarlint receiving textDocument/didChange event, see https://gitlab.com/schrieveslaach/sonarlint.nvim/-/issues/23
        flags = {
          debounce_text_changes = 1000,
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
  local st_path = os.getenv('SPRING_BOOT_TOOLS_PATH') or '.'
  require('spring_boot').setup({
    ls_path = st_path .. '/language-server',
    server = {
      cmd = util.java_cmd_optimize('java', {
        '-Xmx1G',
        '-Dsts.lsp.client=vscode',
        '-jar',
        vim.fn.glob(st_path .. '/language-server/*.jar'),
      }),
    },
  })
  require('java-deps').setup()
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
  map('n', '<leader>cf', list_workspace_folders, 'Lsp list workspace folder')
end)
