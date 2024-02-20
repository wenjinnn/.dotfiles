return {
  {
    'nvim-lua/lsp-status.nvim',
    lazy = true,
    config = function()
      local lsp_status = require('lsp-status')
      lsp_status.register_progress();
      lsp_status.config({
        diagnostics = false,
        status_symbol = ''
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    cond = not vim.g.vscode,
    event = 'BufRead',
    keys = {
      { '<leader>P',  '<cmd>lua print(require("lsp-status").status())<CR>' },
      { 'K',          '<cmd>lua vim.lsp.buf.hover()<CR>' },
      { 'gD',         '<cmd>lua vim.lsp.buf.declaration()<CR>' },
      {'<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>'},
      {'<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>'},
      {'<leader>k', '<cmd>lua vim.lsp.buf.signature_help()<CR>'},
      {'<leader>K', '<cmd>norm! K<CR>'},
      {'<leader>D', '<cmd>lua vim.diagnostic.open_float()<CR>'},
      {'[q', '<cmd>cprev<CR>'},
      {']q', '<cmd>cnext<CR>'},
      {'[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>'},
      {']d', '<cmd>lua vim.diagnostic.goto_next()<CR>'},
      {'[e', '<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })<CR>'},
      {']e', '<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })<CR>'},
      {'[w', '<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })<CR>'},
      {']w', '<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })<CR>'},
      {'<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>'},
      {'<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>'},
      {'<leader>wl', '<cmd>lua vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>'},
      {'<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>'},
      {'<leader>Q', '<cmd>lua vim.diagnostic.setloclist()<CR>'},
      {'<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>'},
      {'<leader>n', '<cmd>lua vim.diagnostic.hide(nil, 0)<CR>'},
      {'<leader>N', '<cmd>lua vim.diagnostic.show(nil, 0)<CR>'},
    },
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = { PATH = 'append' },
      },
      {
        'williamboman/mason-lspconfig.nvim',
        config = function()
          local common = require('lsp.common')
          local textdomain = os.getenv('TEXTDOMAIN')
          require('mason-lspconfig').setup()
          require('util').mason_package_init()
          require('mason-lspconfig').setup_handlers({
            -- The first entry (without a key) will be the default handler
            -- and will be called for each installed server that doesn't have
            -- a dedicated handler.
            function(server_name) -- default handler (optional)
              if vim.o.diff or textdomain == 'git' then
                return
              end
              -- vim.lsp.set_log_level('debug')
              if server_name ~= 'jdtls' then
                local lsp_config_path = 'lsp.' .. server_name
                local capabilities = common.make_capabilities()
                local config = {
                  -- enable snippet support
                  capabilities = capabilities,
                  -- map buffer local keybindings when the language server attaches
                  on_attach = function(client, bufnr)
                    common.setup(client, bufnr)
                    if pcall(require, lsp_config_path) and require(lsp_config_path).attach ~= nil then
                      require(lsp_config_path).attach(client, bufnr)
                    end
                  end
                }
                local settings = lsp_config_path .. '.settings'
                if pcall(require, settings) then
                  config.settings = require(settings)
                end
                require('lspconfig')[server_name].setup(config)
              else
                local jdtls = require('lsp.jdtls')
                -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
                vim.api.nvim_create_augroup('user_jdtls_setup', { clear = true })
                vim.api.nvim_create_autocmd(
                  { 'FileType' },
                  { group = 'user_jdtls_setup', pattern = 'java,ant', callback = jdtls.setup })
                vim.api.nvim_create_autocmd(
                  { 'FileType' },
                  {
                    group = 'user_jdtls_setup',
                    pattern = 'xml',
                    callback = function()
                      local name = vim.fn.expand('%:t')
                      if name == 'pom.xml' then
                        jdtls.setup()
                      end
                    end
                  })
              end
            end,
            -- -- Next, you can provide targeted overrides for specific servers.
            -- -- For example, a handler override for the `rust_analyzer`:
            -- ["rust_analyzer"] = function ()
            --     require("rust-tools").setup {}
            -- end
            ['groovyls'] = function()
              require('lspconfig').groovyls.setup {
                root_dir = require('lspconfig.util').find_git_ancestor
              }
            end,
            -- ['lemminx'] = function()
            --   local lemminx_jars = {}
            --   for _, bundle in ipairs(vim.split(vim.fn.glob('/home/hewenjin/.lemminx/' .. '/*.jar'), '\n')) do
            --     table.insert(lemminx_jars, bundle)
            --   end
            --   require 'lspconfig'.lemminx.setup {
            --     cmd = {
            --       'java',
            --       -- 'lemminx',
            --       '-cp',
            --       vim.fn.join(lemminx_jars, ':'),
            --       'org.eclipse.lemminx.XMLServerLauncher'
            --     }
            --   }
            -- end
          })
      end},
      { 'b0o/SchemaStore.nvim' },
      { 'onsails/lspkind.nvim' },
      {
        'VidocqH/lsp-lens.nvim',
        opts = {
          sections = { -- Enable / Disable specific request, formatter example looks 'Format Requests'
            definition = true,
            references = true,
            implements = true,
            git_authors = true,
          }
        }
      },
      {
        'mfussenegger/nvim-jdtls',
        keys = {
          { '<leader>cC', '<cmd>JdtCompile full<CR>' },
          { '<leader>cc', '<cmd>JdtCompile incremental<CR>' },
          { '<leader>ch', '<cmd>JdtHotcodeReplace<CR>' },
          { 'gt',         '<cmd>lua require("jdtls.tests").goto_subjects()<CR>' },
          { '<leader>cg', '<cmd>lua require("jdtls.tests").generate()<CR>' },
        }
      },
      {
        url = 'https://gitlab.com/schrieveslaach/sonarlint.nvim',
        opts = {
          server = {
            cmd = {
              'sonarlint-language-server',
              -- Ensure that sonarlint-language-server uses stdio channel
              '-stdio',
              '-analyzers',
              -- paths to the analyzers you need, using those for python and java in this example
              vim.fn.expand('$MASON/share/sonarlint-analyzers/sonarpython.jar'),
              vim.fn.expand('$MASON/share/sonarlint-analyzers/sonarcfamily.jar'),
              vim.fn.expand('$MASON/share/sonarlint-analyzers/sonarjava.jar'),
            }
          },
          filetypes = {
            -- Tested and working
            'python',
            'cpp',
            -- Requires nvim-jdtls, otherwise an error message will be printed
            'java',
          }
        }
      },
      {
        'nvimtools/none-ls.nvim',
        main = 'null-ls',
        opts = function()
          local null_ls = require('null-ls')
          -- register any number of sources simultaneously
          local sources = {
            -- null_ls.builtins.formatting.google_java_format,
            null_ls.builtins.diagnostics.cspell.with({
              diagnostics_postprocess = function(diagnostic)
                diagnostic.severity = vim.diagnostic.severity['INFO']
              end,
            }),
            null_ls.builtins.code_actions.cspell,
            null_ls.builtins.code_actions.gitsigns,
          }
          return { sources = sources }
        end
      },
      {
        'ahmedkhalf/project.nvim',
        main = 'project_nvim',
        opts = {
          -- All the patterns used to detect root dir, when **"pattern"** is in
          detection_methods = { 'lsp', 'pattern' },
          -- detection_methods
          patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json' },
          -- Show hidden files in telescope
          show_hidden = true,
          silent_chdir = false,
        }
      }
    },
    config = function()
    end
  },
}
