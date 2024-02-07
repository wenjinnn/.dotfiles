return {
  { 'nvim-lua/lsp-status.nvim', cond = not vim.g.vscode, },
  { 'onsails/lspkind.nvim',     cond = not vim.g.vscode, }, -- enhancement for jdtls
  { 'mfussenegger/nvim-jdtls',  cond = not vim.g.vscode, },
  {
    url = 'https://gitlab.com/schrieveslaach/sonarlint.nvim',
    cond = not vim.g.vscode,
    config = function()
      require('sonarlint').setup({
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
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    cond = not vim.g.vscode,
    dependencies = {
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'b0o/SchemaStore.nvim' },
    },
    config = function()
      require('mason').setup({
        PATH = 'append',
        registries = {
          'github:nvim-java/mason-registry',
          'github:mason-org/mason-registry',
        },
      })
      local installed_pkgs = require('mason-registry').get_installed_packages()
      local install_confirm = ''
      if #installed_pkgs == 0 then
        install_confirm = vim.fn.input('No package installed yet, install default package now ? (via Mason) Y/n = ')
      end

      install_confirm = string.lower(install_confirm)

      if install_confirm == 'y' then
        vim.cmd([[
      MasonInstall
      \ typescript-language-server
      \ dot-language-server
      \ cspell
      \ vim-language-server
      \ emmet-ls
      \ html-lsp
      \ prettier
      \ sqlls
      \ python-lsp-server
      \ yaml-language-server
      \ lemminx
      \ luaformatter
      \ lua-language-server
      \ marksman
      \ vuels
      \ jdtls
      \ vscode-java-decompiler
      \ java-debug-adapter
      \ java-test
      \ google-java-format
      \ pyright
      \ bash-language-server
      \ eslint-lsp
      \ rust-analyzer
      \ clang-format
      \ taplo
      \ clangd
      \ codelldb
      \ cpplint
      \ cpptools
      \ gradle-language-server
      \ glow
      \ sonarlint-language-server
      \ jq
      \ jsonls
    ]])
      end
      local lsp_status = require('lsp-status')
      lsp_status.register_progress();
      lsp_status.config({
        diagnostics = false,
        status_symbol = ''
      })

      local common = require('lsp.common')
      local textdomain = os.getenv('TEXTDOMAIN')
      require('mason-lspconfig').setup()
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
    end
  },
  {
    'nvimtools/none-ls.nvim',
    cond = not vim.g.vscode,
    config = function()
      local null_ls = require("null-ls")

      -- register any number of sources simultaneously
      local sources = {
        -- null_ls.builtins.formatting.google_java_format,
        null_ls.builtins.diagnostics.cspell.with({
          diagnostics_postprocess = function(diagnostic)
            diagnostic.severity = vim.diagnostic.severity["INFO"]
          end,
        }),
        null_ls.builtins.code_actions.cspell,
        null_ls.builtins.code_actions.gitsigns,
      }
      null_ls.setup({ sources = sources })
    end
  },
  {
    'ahmedkhalf/project.nvim',
    cond = not vim.g.vscode,
    config = function()
      require('project_nvim').setup({
        -- All the patterns used to detect root dir, when **"pattern"** is in
        detection_methods = { 'lsp', 'pattern' },
        -- detection_methods
        patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json' },
        -- Show hidden files in telescope
        show_hidden = true,
        silent_chdir = false,
      })
    end
  }
}
