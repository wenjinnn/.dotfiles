local not_vscode = require("util").not_vscode
return {
  {
    "neovim/nvim-lspconfig",
    cond = not_vscode,
    event = { "BufRead", "SessionLoadPost" },
    config = function()
      local lsp = require("lsp")
      local util = require("util.lsp")
      for server_name, config in pairs(lsp) do
        if config.setup ~= nil and type(config.setup) == "function" then
          config.setup()
        else
          local final_config = util.make_lspconfig(config)
          require("lspconfig")[server_name].setup(final_config)
        end
      end
    end,
    dependencies = {
      { "b0o/SchemaStore.nvim" },
      { "mfussenegger/nvim-jdtls" },
      {
        url = "https://gitlab.com/schrieveslaach/sonarlint.nvim",
        lazy = true,
        opts = function()
          local sonarlint_path = os.getenv("SONARLINT_PATH") or vim.fn.stdpath("data") .. "/sonarlint"
          return {
            server = {
              cmd = {
                "java",
                "-jar",
                sonarlint_path .. "/server/sonarlint-ls.jar",
                -- Ensure that sonarlint-language-server uses stdio channel
                "-stdio",
                "-analyzers",
                -- paths to the analyzers you need, using those for python and java in this example
                sonarlint_path .. "/analyzers/sonarpython.jar",
                sonarlint_path .. "/analyzers/sonarcfamily.jar",
                sonarlint_path .. "/analyzers/sonarjava.jar",
              },
              settings = require("lsp.sonarlint-language-server").settings,
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
    keys = {
      {
        "<leader>ca",
        "<cmd>lua vim.lsp.buf.code_action()<CR>",
        mode = { "n", "v" },
        desc = "Lsp code action",
      },
      {
        "<leader>cl",
        "<cmd>lua vim.lsp.codelens.run()<cr>",
        desc = "Run codelens",
      },
      {
        "<leader>cL",
        "<cmd>lua vim.lsp.codelens.refresh()<cr>",
        desc = "Refresh codelens",
      },
      {
        "<leader>cH",
        "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({bufnr = 0}), {bufnr = 0})<cr>",
        desc = "Lsp inlay hint toggle",
      },
      {
        "<leader>k",
        "<cmd>lua vim.lsp.buf.signature_help()<CR>",
        desc = "Lsp signature help",
      },
      {
        "<leader>cw",
        "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>",
        desc = "Lsp add workspace folder",
      },
      {
        "<leader>cW",
        "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>",
        desc = "Lsp remove workspace folder",
      },
      {
        "<leader>cf",
        "<cmd>lua vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
        desc = "Lsp list workspace folder",
      },
      { "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Lsp rename" },
      {
        "<leader>Q",
        "<cmd>lua vim.diagnostic.setloclist()<CR>",
        desc = "Lsp diagnostic location list",
      },
      {
        "<leader>cI",
        "<cmd>lua vim.lsp.buf.incoming_calls()<CR>",
        desc = "Lsp incoming calls",
      },
      {
        "<leader>ch",
        "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>",
        desc = "Lsp outgoing calls",
      },
    },
  },
}
