local not_vscode = require("util").not_vscode
return {
  {
    "neovim/nvim-lspconfig",
    cond = not_vscode,
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
        "<leader>cl",
        vim.lsp.codelens.run,
        desc = "Run Codelens",
        mode = { "n", "v" },
      },
      {
        "<leader>cL",
        vim.lsp.codelens.refresh,
        desc = "Refresh & Display Codelens",
        mode = { "n" },
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
      {
        "<leader><leader>D",
        "<cmd>lua MiniBasics.toggle_diagnostic()<CR>",
        desc = "Toggle Diagnostic",
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
      {
        "<leader>Q",
        "<cmd>lua vim.diagnostic.setloclist()<CR>",
        desc = "Lsp Diagnostic Location List",
      },
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
        "gR",
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
            function(server_name)
              -- default handler
              -- vim.lsp.set_log_level('debug')
              local config = {
                capabilities = lsp.make_capabilities(),
                inlay_hints = { enabled = true },
                codelens = { enabled = true },
                document_highlight = { enabled = true },
                on_attach = function(client, bufnr)
                  lsp.setup(client, bufnr)
                end,
              }
              local lsp_config_module = "lsp." .. server_name
              local module_exist = pcall(require, lsp_config_module)
              if module_exist and type(require(lsp_config_module)) == "table" then
                local lsp_config = require(lsp_config_module)
                for key, val in pairs(lsp_config) do
                  config[key] = val
                end
              end

              require("lspconfig")[server_name].setup(config)
            end,
            -- -- Next, you can provide targeted overrides for specific servers.
            -- -- For example, a handler override for the `rust_analyzer`:
            -- ["rust_analyzer"] = function ()
            --     require("rust-tools").setup {}
            -- end
            jdtls = function()
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
            end,
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
        opts = function()
          local mason_pkg_path = require("util.lsp").get_mason_pkg_path()
          return {
            server = {
              cmd = {
                "sonarlint-language-server",
                -- Ensure that sonarlint-language-server uses stdio channel
                "-stdio",
                "-analyzers",
                -- paths to the analyzers you need, using those for python and java in this example
                mason_pkg_path .. "/share/sonarlint-analyzers/sonarpython.jar",
                mason_pkg_path .. "/share/sonarlint-analyzers/sonarcfamily.jar",
                mason_pkg_path .. "/share/sonarlint-analyzers/sonarjava.jar",
              },
            },
            filetypes = {
              -- Tested and working
              "python",
              "cpp",
              -- Requires nvim-jdtls, otherwise an error message will be printed
              "java",
            },
          }
        end,
      },
      {
        "nvimtools/none-ls.nvim",
        main = "null-ls",
        opts = function()
          local null_ls = require("null-ls")
          local cspell = require("cspell")
          -- register any number of sources simultaneously
          local sources = {
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
