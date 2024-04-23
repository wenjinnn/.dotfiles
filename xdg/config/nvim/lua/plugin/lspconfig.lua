local not_vscode = require("util").not_vscode
return {
  {
    "neovim/nvim-lspconfig",
    cond = not_vscode or not vim.o.diff,
    event = "BufRead",
    keys = {
      { "K", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "Lsp Hover" },
      { "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", desc = "Lsp Declaration" },
      {
        "<leader>ca",
        "<cmd>lua vim.lsp.buf.code_action()<CR>",
        mode = { "n", "v" },
        desc = "Code Action",
      },
      {
        "<leader>k",
        "<cmd>lua vim.lsp.buf.signature_help()<CR>",
        desc = "Lsp Signature Help",
      },
      {
        "<leader>D",
        "<cmd>lua vim.diagnostic.open_float()<CR>",
        desc = "Diagnostic Float",
      },
      { "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", desc = "Prev Diagnostic" },
      { "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", desc = "Next Diagnostic" },
      {
        "[e",
        "<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>",
        desc = "Prev Error Diagnostic",
      },
      {
        "]e",
        "<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>",
        desc = "Next Error Diagnostic",
      },
      {
        "[w",
        "<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })<CR>",
        desc = "Prev Warn Diagnostic",
      },
      {
        "]w",
        "<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })<CR>",
        desc = "Prev Warn Diagnostic",
      },
      {
        "<leader>wa",
        "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>",
        desc = "Lsp Add Workspace Folder",
      },
      {
        "<leader>wr",
        "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>",
        desc = "Lsp Remove Workspace Folder",
      },
      {
        "<leader>wl",
        "<cmd>lua vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
        desc = "Lsp List Workspace Folder",
      },
      { "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Lsp Rename" },
      { "<leader>Q", "<cmd>lua vim.diagnostic.setloclist()<CR>", desc = "Lsp Diagnostic Loclist" },
      { "<leader>n", "<cmd>lua vim.diagnostic.hide(nil, 0)<CR>", desc = "Hide Diagnostic" },
      { "<leader>N", "<cmd>lua vim.diagnostic.show(nil, 0)<CR>", desc = "Show Diagnostic" },
      {
        "<leader>fws",
        "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
        desc = "Telescope Lsp Dynamic Workspace Symbols",
      },
      {
        "<leader>fwS",
        "<cmd>Telescope lsp_document_symbols<cr>",
        desc = "Telescope Lsp Document Symbols",
      },
      { "gd", "<cmd>Telescope lsp_definitions<CR>", desc = "Telescope Lsp Definitions" },
      {
        "gi",
        "<cmd>Telescope lsp_implementations<CR>",
        desc = "Telescope Lsp Implementations",
      },
      {
        "gI",
        "<cmd>Telescope lsp_incoming_calls<CR>",
        desc = "Telescope Lsp Incoming Calls",
      },
      {
        "gO",
        "<cmd>Telescope lsp_outgoing_calls<CR>",
        desc = "Telescope Lsp_outgoing Calls",
      },
      {
        "gr",
        "<cmd>Telescope lsp_references show_line=false include_declaration=false<CR>",
        desc = "Telescope Lsp References",
      },
    },
    dependencies = {
      {
        "linrongbin16/lsp-progress.nvim",
        module = false,
        opts = {
          format = function(client_messages)
            -- icon: nf-fa-gear \uf013
            local sign = " LSP"
            if #client_messages > 0 then
              return sign .. " " .. table.concat(client_messages, " ")
            end
            if #vim.lsp.get_active_clients() > 0 then
              return ""
            end
            return ""
          end,
        },
      },
      {
        "SmiteshP/nvim-navic",
        module = false,
        opts = {
          lsp = {
            auto_attach = true,
            preference = { "pyright" },
          },
          click = true,
        },
      },
      {
        "williamboman/mason.nvim",
        opts = { PATH = "append" },
        cmd = "Mason",
      },
      {
        "williamboman/mason-lspconfig.nvim",
        config = function()
          local lsp = require("util.lsp")
          require("mason-lspconfig").setup()
          require("util").mason_package_init()
          require("mason-lspconfig").setup_handlers({
            -- The first entry (without a key) will be the default handler
            -- and will be called for each installed server that doesn't have
            -- a dedicated handler.
            function(server_name) -- default handler (optional)
              -- vim.lsp.set_log_level('debug')
              if server_name ~= "jdtls" then
                local lsp_config_path = "lsp." .. server_name
                local capabilities = lsp.make_capabilities()
                local config = {
                  -- enable snippet support
                  capabilities = capabilities,
                  -- map buffer local keybindings when the language server attaches
                  on_attach = function(client, bufnr)
                    lsp.setup(client, bufnr)
                    if
                      pcall(require, lsp_config_path) and require(lsp_config_path).attach ~= nil
                    then
                      require(lsp_config_path).attach(client, bufnr)
                    end
                  end,
                }
                local settings = lsp_config_path .. ".settings"
                if pcall(require, settings) then
                  config.settings = require(settings)
                end
                require("lspconfig")[server_name].setup(config)
              else
                local jdtls = require("lsp.jdtls")
                -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
                vim.api.nvim_create_augroup("user_jdtls_setup", { clear = true })
                vim.api.nvim_create_autocmd(
                  { "FileType" },
                  { group = "user_jdtls_setup", pattern = "java,ant", callback = jdtls.setup }
                )
                vim.api.nvim_create_autocmd({ "FileType" }, {
                  group = "user_jdtls_setup",
                  pattern = "xml",
                  callback = function()
                    local name = vim.fn.expand("%:t")
                    if name == "pom.xml" then
                      jdtls.setup()
                    end
                  end,
                })
              end
            end,
            -- -- Next, you can provide targeted overrides for specific servers.
            -- -- For example, a handler override for the `rust_analyzer`:
            -- ["rust_analyzer"] = function ()
            --     require("rust-tools").setup {}
            -- end
            ["groovyls"] = function()
              require("lspconfig").groovyls.setup({
                root_dir = require("lspconfig.util").find_git_ancestor,
              })
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
        end,
      },
      { "b0o/SchemaStore.nvim" },
      { "onsails/lspkind.nvim" },
      {
        "mfussenegger/nvim-jdtls",
        keys = {
          {
            "<leader>cC",
            "<cmd>JdtCompile full<CR>",
            desc = "JdtCompile full",
          },
          {
            "<leader>cc",
            "<cmd>JdtCompile incremental<CR>",
            desc = "JdtCompile incremental",
          },
          {
            "<leader>ch",
            "<cmd>JdtUpdateHotcode<CR>",
            desc = "JdtUpdateHotcode",
          },
          {
            "gt",
            '<cmd>lua require("jdtls.tests").goto_subjects()<CR>',
            desc = "Jdt Test Goto Subjects",
          },
          {
            "<leader>cg",
            '<cmd>lua require("jdtls.tests").generate()<CR>',
            desc = "Jdt Test Generate",
          },
        },
      },
      {
        url = "https://gitlab.com/schrieveslaach/sonarlint.nvim",
        opts = {
          server = {
            cmd = {
              "sonarlint-language-server",
              -- Ensure that sonarlint-language-server uses stdio channel
              "-stdio",
              "-analyzers",
              -- paths to the analyzers you need, using those for python and java in this example
              vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
              vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
              vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
            },
          },
          filetypes = {
            -- Tested and working
            "python",
            "cpp",
            -- Requires nvim-jdtls, otherwise an error message will be printed
            "java",
          },
        },
      },
      {
        "nvimtools/none-ls.nvim",
        main = "null-ls",
        opts = function()
          local null_ls = require("null-ls")
          local cspell = require("cspell")
          -- register any number of sources simultaneously
          local sources = {
            -- null_ls.builtins.formatting.google_java_format,
            -- null_ls.builtins.diagnostics.cspell.with({
            --   diagnostics_postprocess = function(diagnostic)
            --     diagnostic.severity = vim.diagnostic.severity["INFO"]
            --   end,
            -- }),
            cspell.diagnostics.with({
              diagnostics_postprocess = function(diagnostic)
                diagnostic.severity = vim.diagnostic.severity["INFO"]
              end,
            }),
            cspell.code_actions,
            null_ls.builtins.code_actions.gitsigns,
          }
          return { sources = sources }
        end,
      },
      { "davidmh/cspell.nvim" },
    },
  },
}
