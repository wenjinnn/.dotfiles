local not_vscode = require("util").not_vscode
return {
  {
    "michaelb/sniprun",
    event = "CmdLineEnter",
    build = "sh ./install.sh 1",
    opts = {
      repl_enable = { "Lua_nvim" },
      selected_interpreters = { "Lua_nvim" },
      live_mode_toggle = "enable",
    },
    keys = {
      { "<leader>rs", "<Plug>SnipRun", desc = "Run snip", mode = { "n", "v" } },
      { "<leader>rS", "<Plug>SnipRunOperator", desc = "Run snip operator" },
    },
  },
  {
    "jellydn/hurl.nvim",
    cond = not_vscode,
    ft = "hurl",
    lazy = true,
    opts = {
      show_notification = true,
      env_file = {
        ".envrc",
        ".env",
        "vars.env",
        "hurl.env",
      },
    },
    keys = {
      -- Run API request
      { "<leader>rA", "<cmd>HurlRunner<CR>", desc = "Run all requests" },
      { "<leader>ra", "<cmd>HurlRunnerAt<CR>", desc = "Run api request" },
      { "<leader>re", "<cmd>HurlRunnerToEntry<CR>", desc = "Run api request to entry" },
      { "<leader>rt", "<cmd>HurlToggleMode<CR>", desc = "Hurl toggle mode" },
      { "<leader>rv", "<cmd>HurlVerbose<CR>", desc = "Run api in verbose mode" },
      -- Run Hurl request in visual mode
      { "<leader>ra", ":HurlRunner<CR>", desc = "Hurl runner", mode = "v" },
    },
  },
  -- markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cond = not_vscode,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview toggle" },
    },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
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
    end,
    ft = { "markdown" },
  },
  -- neovim in browser
  {
    "glacambre/firenvim",
    cond = not_vscode,
    lazy = not vim.g.started_by_firenvim,
    init = function()
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
    end,
    build = ":call firenvim#install(0)",
    config = function()
      vim.api.nvim_set_keymap(
        "n",
        "<Esc><Esc>",
        "<Cmd>call firenvim#focus_page()<CR>",
        { desc = "Firenvim focus page" }
      )
    end,
  },
  -- db manage
  {
    "kristijanhusak/vim-dadbod-ui",
    init = function()
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
    end,
    dependencies = {
      { "tpope/vim-dadbod" },
    },
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "DBUI toggle" },
    },
    ft = { "sql", "mysql", "plsql" },
    cond = not_vscode,
    cmd = "DBUIToggle",
  },
  -- search and replace tool
  {
    "MagicDuck/grug-far.nvim",
    cond = not_vscode,
    opts = {
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
    },
    keys = {
      {
        "<leader>Fg",
        "<cmd>GrugFar<CR>",
        desc = "Toggle GrugFar",
      },
      {
        "<leader>Fv",
        '<cmd>lua require("grug-far").grug_far({ prefills = { search = vim.fn.expand("<cword>") } })<CR>',
        mode = { "n", "v" },
        desc = "GrugFar search current word",
      },
      {
        "<leader>Ff",
        '<cmd>lua require("grug-far").grug_far({ prefills = { paths = vim.fn.expand("%") } })<CR>',
        desc = "Search on current file",
      },
    },
  },
  {
    "jbyuki/venn.nvim",
    cmd = { "VBox" },
    keys = {
      { "<leader>vv", ":VBox<cr>", mode = "v", desc = "Draw a single line box or arrow" },
      { "<leader>vd", ":VBoxD<cr>", mode = "v", desc = "Draw a double line box or arrow" },
      { "<leader>vh", ":VBoxH<cr>", mode = "v", desc = "Draw a heavy line box or arrow" },
      { "<leader>vo", ":VBoxO<cr>", mode = "v", desc = "Draw over a existing box or arrow" },
      { "<leader>vO", ":VBoxDO<cr>", mode = "v", desc = "Draw over a doulbe line on a existing box or arrow" },
      { "<leader>vH", ":VBoxHO<cr>", mode = "v", desc = "Draw over a heavy line on a existing box or arrow" },
      { "<leader>vf", ":VFill<cr>", mode = "v", desc = "Draw fill a area with a solid color" },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    event = "BufRead",
    opts = function()
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
      return {
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
          ["Senior Developer"] = { opts = { mapping = "<Leader>Cs" } },
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
      }
    end,
    keys = {
      { mode = { "n", "v" }, "<leader>Ca", "<cmd>CodeCompanionActions<cr>", desc = "Code companion actions" },
      { "<leader>Cc", "<cmd>CodeCompanion<cr>", desc = "Code companion" },
      { "<leader>CC", "<cmd>CodeCompanionChat<cr>", desc = "Code companion chat" },
      { mode = { "n", "v" }, "<leader>CT", "<cmd>CodeCompanionToggle<cr>", desc = "Code companion toggle" },
      { mode = { "v" }, "<leader>CA", "<cmd>CodeCompanionAdd<cr>", desc = "Code companion add" },
    },
  },
}
