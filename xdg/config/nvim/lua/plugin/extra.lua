local in_vscode = require("util").in_vscode
local map = vim.keymap.set
local add, later = MiniDeps.add, MiniDeps.later

later(function()
  add({
    source = "michaelb/sniprun",
    hooks = {
      post_checkout = function()
        vim.cmd("sh ./install.sh 1")
      end,
    },
  })

  require("sniprun").setup({
    repl_enable = { "Lua_nvim" },
    selected_interpreters = { "Lua_nvim" },
    live_mode_toggle = "enable",
  })
  map({ "n", "v" }, "<leader>rs", "<Plug>SnipRun", { desc = "Run snip" })
  map("n", "<leader>rS", "<Plug>SnipRunOperator", { desc = "Run snip operator" })
end)

later(function()
  -- ascii draw in neovim
  add({ source = "jbyuki/venn.nvim" })
  map("v", "<leader>vv", ":VBox<cr>", { desc = "Draw a single line box or arrow" })
  map("v", "<leader>vd", ":VBoxD<cr>", { desc = "Draw a double line box or arrow" })
  map("v", "<leader>vh", ":VBoxH<cr>", { desc = "Draw a heavy line box or arrow" })
  map("v", "<leader>vo", ":VBoxO<cr>", { desc = "Draw over a existing box or arrow" })
  map("v", "<leader>vO", ":VBoxDO<cr>", { desc = "Draw over a doulbe line on a existing box or arrow" })
  map("v", "<leader>vH", ":VBoxHO<cr>", { desc = "Draw over a heavy line on a existing box or arrow" })
  map("v", "<leader>vf", ":VFill<cr>", { desc = "Draw fill a area with a solid color" })
end)

if not in_vscode() then
  -- hurl client
  later(function()
    add({
      source = "jellydn/hurl.nvim",
      depends = { "MunifTanjim/nui.nvim" },
    })
    require("hurl").setup({
      show_notification = true,
      env_file = {
        ".envrc",
        ".env",
        "vars.env",
        "hurl.env",
      },
    })
    -- Run API request
    map("n", "<leader>rA", "<cmd>HurlRunner<CR>", { desc = "Run all requests" })
    map("n", "<leader>ra", "<cmd>HurlRunnerAt<CR>", { desc = "Run api request" })
    map("n", "<leader>re", "<cmd>HurlRunnerToEntry<CR>", { desc = "Run api request to entry" })
    map("n", "<leader>rt", "<cmd>HurlToggleMode<CR>", { desc = "Hurl toggle mode" })
    map("n", "<leader>rv", "<cmd>HurlVerbose<CR>", { desc = "Run api in verbose mode" })
    -- Run Hurl request in visual mode
    map("v", "<leader>ra", ":HurlRunner<CR>", { desc = "Hurl runner" })
  end)

  -- markdown preview in browser
  later(function()
    add({
      source = "iamcco/markdown-preview.nvim",
      hooks = {
        post_checkout = function()
          vim.fn["mkdp#util#install"]()
        end,
      },
    })
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = { theme = "dark" },
      disable_sync_scroll = 0,
      sync_scroll_type = "middle",
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {},
    }
    map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown preview toggle" })
  end)
  -- neovim in browser
  later(function()
    add({
      source = "glacambre/firenvim",
      hooks = {
        post_checkout = function()
          vim.fn["firenvim#install"](0)
        end,
      },
    })
    vim.g.firenvim_config = {
      globalSettings = { alt = "all" },
      localSettings = {
        [".*"] = {
          cmdline = "firenvim",
          content = "text",
          priority = 0,
          selector = "textarea:not([readonly], [aria-readonly])",
          takeover = "never",
        },
      },
    }
    if vim.g.started_by_firenvim then
      map(
        "n",
        "<C-[>",
        "<Cmd>call firenvim#focus_page()<CR>",
        { desc = "Firenvim focus page" }
      )
    end
  end)
  -- db manage
  later(function()
    add({
      source = "tpope/vim-dadbod",
      depends = { "kristijanhusak/vim-dadbod-ui" },
    })
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_queries"
    vim.g.vim_dadbod_completion_mark = ""
    -- set filetype to sql to make snip completion work
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "mysql,plsql",
      callback = function()
        vim.bo.filetype = "sql"
      end,
    })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "sql",
      callback = function()
        vim.api.nvim_set_keymap(
          "x",
          "<leader>rq",
          "db#op_exec()",
          { expr = true, desc = "DB exec current query" }
        )
      end,
    })
    map("n", "<leader>D", "<cmd>DBUIToggle<cr>", { desc = "DBUI toggle" })
  end)

  -- search and replace tool
  later(function()
    add({ source = "MagicDuck/grug-far.nvim" })

    require("grug-far").setup({
      keymaps = {
        replace = { n = "<localleader>Fr" },
        qflist = { n = "<localleader>Fq" },
        syncLocations = { n = "<localleader>Fs" },
        syncLine = { n = "<localleader>FS" },
        close = { n = "<localleader>Fc" },
        historyOpen = { n = "<localleader>Fh" },
        historyAdd = { n = "<localleader>FH" },
        refresh = { n = "<localleader>FR" },
        openLocation = { n = "<localleader>Fo" },
        abort = { n = "<localleader>Fb" },
        toggleShowCommand = { n = "<localleader>Ft" },
        swapEngine = { n = "<localleader>Fe" },
      },
    })
  end)

  map("n", "<leader>Fg",
    "<cmd>GrugFar<CR>",
    { desc = "Toggle GrugFar" })
  map({ "n", "v" }, "<leader>Fv",
    function()
      require("grug-far").grug_far({ prefills = { search = vim.fn.expand("<cword>") } })
    end,
    { desc = "GrugFar search current word" })
  map("n", "<leader>Ff", function()
      require("grug-far").grug_far({ prefills = { paths = vim.fn.expand("%") } })
    end,
    { desc = "Search on current file" }
  )
  -- AI companion
  later(function()
    add({ source = "olimorris/codecompanion.nvim" })
    local adapter = "anthropic"
    if vim.fn.has("ollama") == 1 then
      local handle = io.popen("ollama ps")
      if handle then
        for line in handle:lines() do
          local first_word = line:match("%S+")
          if first_word ~= nil and first_word ~= "NAME" then
            adapter = "ollama"
            break
          end
        end
      end
    end
    require("codecompanion").setup({
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").use("anthropic", {
            env = {
              api_key = "cmd:sops exec-env $SOPS_SECRETS 'echo -n $ANTHROPIC_API_KEY'",
            },
          })
        end,
        ollama = function()
          return require("codecompanion.adapters").use("ollama", {
            schema = {
              model = {
                default = "llama3.1",
              },
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = adapter },
        inline = { adapter = adapter },
        agent = { adapter = adapter },
      },
      default_prompts = {
        ["Custom Prompt"] = { opts = { mapping = "<Leader>Cp" } },
        ["Explain"] = { opts = { mapping = "<Leader>Ce" } },
        ["Unit Tests"] = { opts = { mapping = "<Leader>Ct" } },
        ["Fix code"] = { opts = { mapping = "<Leader>Cf" } },
        ["Buffer selection"] = { opts = { mapping = "<Leader>Cb" } },
        ["Explain LSP Diagnostics"] = { opts = { mapping = "<Leader>Cl" } },
        ["Generate a Commit Message"] = { opts = { mapping = "<Leader>Cm" } },
      },
      display = {
        chat = {
          show_settings = true,
        },
      },
    })
  end)
  map({ "n", "v" }, "<leader>Ca", "<cmd>CodeCompanionActions<cr>", { desc = "Code companion actions" })
  map("n", "<leader>CC", "<cmd>CodeCompanionChat<cr>", { desc = "Code companion chat" })
  map({ "n", "v" }, "<leader>CT", "<cmd>CodeCompanionToggle<cr>", { desc = "Code companion toggle" })
  map("v", "<leader>CA", "<cmd>CodeCompanionAdd<cr>", { desc = "Code companion add" })
end
