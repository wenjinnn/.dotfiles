local not_vscode = require("util").not_vscode
return {
  {
    "neovim/nvim-lspconfig",
    cond = not_vscode,
    event = "BufRead",
    keys = {
      {
        "<leader>ca",
        "<cmd>lua vim.lsp.buf.code_action()<CR>",
        mode = { "n", "v" },
        desc = "Lsp code action",
      },
      {
        "<leader>cl",
        vim.lsp.codelens.run,
        desc = "Run codelens",
        mode = { "n", "v" },
      },
      {
        "<leader>cL",
        vim.lsp.codelens.refresh,
        desc = "Refresh codelens",
        mode = { "n" },
      },
      {
        "<leader>k",
        "<cmd>lua vim.lsp.buf.signature_help()<CR>",
        desc = "Lsp signature help",
      },
      {
        "<leader>D",
        "<cmd>lua vim.diagnostic.open_float()<CR>",
        desc = "Diagnostic float",
      },
      {
        "<leader><leader>D",
        "<cmd>lua MiniBasics.toggle_diagnostic()<CR>",
        desc = "Toggle diagnostic",
      },
      {
        "<leader>wa",
        "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>",
        desc = "Lsp add workspace folder",
      },
      {
        "<leader>wr",
        "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>",
        desc = "Lsp remove workspace folder",
      },
      {
        "<leader>wl",
        "<cmd>lua vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
        desc = "Lsp list workspace folder",
      },
      { "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Lsp rename" },
      {
        "<leader>Q",
        "<cmd>lua vim.diagnostic.setloclist()<CR>",
        desc = "Lsp diagnostic location list",
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
                config = vim.tbl_deep_extend("force", config, lsp_config)
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
      {
        "mfussenegger/nvim-jdtls",
        keys = {
          {
            "<leader>cC",
            "<cmd>JdtCompile full<CR>",
            desc = "Jdt compile full",
          },
          {
            "<leader>cc",
            "<cmd>JdtCompile incremental<CR>",
            desc = "Jdt compile incremental",
          },
          {
            "<leader>cH",
            "<cmd>JdtUpdateHotcode<CR>",
            desc = "Jdt update hotcode",
          },
          {
            "<leader>cg",
            '<cmd>lua require("jdtls.tests").generate()<CR>',
            desc = "Jdt test generate",
          },
        },
      },
      {
        url = "https://gitlab.com/schrieveslaach/sonarlint.nvim",
        opts = function()
          local mason_path = require("util.lsp").get_mason_path()
          return {
            server = {
              cmd = {
                "sonarlint-language-server",
                -- Ensure that sonarlint-language-server uses stdio channel
                "-stdio",
                "-analyzers",
                -- paths to the analyzers you need, using those for python and java in this example
                mason_path .. "/share/sonarlint-analyzers/sonarpython.jar",
                mason_path .. "/share/sonarlint-analyzers/sonarcfamily.jar",
                mason_path .. "/share/sonarlint-analyzers/sonarjava.jar",
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
    },
  },
}
