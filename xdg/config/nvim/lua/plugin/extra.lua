local not_vscode = require("util").not_vscode
return {
  -- rest client
  {
    "NTBBloodbath/rest.nvim",
    cond = not_vscode,
    main = "rest-nvim",
    config = true,
    ft = { "http" },
    keys = {
      { "<leader>re", "<plug>RestNvim", desc = "RestNvim Run" },
      { "<leader>rp", "<plug>RestNvimPreview", desc = "RestNvim Preview" },
      { "<leader>rr", "<plug>RestNvimLast", desc = "RestNvim Run Last" },
    },
  },
  {
    "nvim-orgmode/orgmode",
    cond = not_vscode,
    event = "VeryLazy",
    opts = function()
      require("orgmode").setup_ts_grammar()
      local config = {
        org_agenda_files = { "~/project/my/archive/org/*" },
        notifications = {
          enabled = true,
        },
      }
      local default_notes_file = "~/project/my/archive/org/refile.org"
      default_notes_file = vim.fn.expand(default_notes_file)
      if vim.fn.filereadable(default_notes_file) == 1 then
        config.org_default_notes_file = default_notes_file
      end
      return config
    end,
  },
  -- markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview Toggle" },
    },
    build = "cd app && npm install",
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
    build = function()
      vim.fn["firenvim#install"](0)
    end,
    config = function()
      vim.api.nvim_set_keymap(
        "n",
        "<Esc><Esc>",
        "<Cmd>call firenvim#focus_page()<CR>",
        { desc = "Firenvim Focus Page" }
      )
    end,
  },
  -- db manage
  {
    "kristijanhusak/vim-dadbod-ui",
    init = function()
      vim.g.db_ui_winwidth = 30
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_queries"
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_queries"
      vim.g.dadbod_completion_mark = ""
    end,
    dependencies = {
      { "tpope/vim-dadbod" },
    },
    keys = {
      { "<leader><leader>d", "<cmd>DBUIToggle<cr>", desc = "DBUI Toggle" },
    },
    cond = not_vscode,
    cmd = "DBUIToggle",
  },
  -- powerful replace tool
  {
    "windwp/nvim-spectre",
    cond = not_vscode,
    keys = {
      {
        "<leader>fss",
        '<cmd>lua require("spectre").toggle()<CR>',
        desc = "Toggle Spectre",
      },
      {
        "<leader>fsw",
        '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
        desc = "Spectre Search Current Word",
      },
      {
        "<leader>fsw",
        '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
        mode = "v",
        desc = "Spectre Search Current Word",
      },
      {
        "<leader>fsf",
        '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
        desc = "Search On Current File",
      },
    },
  },
  -- remote develop
  -- {
  --   'miversen33/netman.nvim',
  --   cond = not_vscode,
  --   config = function() require('netman') end
  -- },
  {
    "uga-rosa/translate.nvim",
    cmd = "Translate",
    keys = {
      -- Display translation in a window
      { "<leader>tt", "<cmd>Translate ZH<CR>", mode = { "n", "x" } },
      -- Replace the text with translation
      { "<leader>tr", "<cmd>Translate ZH -output=replace<CR>", mode = { "n", "x" } },
      -- Insert the text with translation
      { "<leader>ti", "<cmd>Translate ZH -output=insert<CR>", mode = { "n", "x" } },
      -- copy translation to register
      { "<leader>ty", "<cmd>Translate ZH -output=register<CR>", mode = { "n", "x" } },
    },
    cond = not_vscode,
    opts = function()
      local default_command = "google"
      if vim.fn.executable("trans") then
        default_command = "translate_shell"
      end
      return {
        default = {
          command = default_command,
        },
      }
    end,
  },
  {
    "folke/which-key.nvim",
    cond = not_vscode,
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
      local wk = require("which-key")
      wk.register({
        f = {
          name = "Telescope Finder",
          i = { name = "BuildIn | Reloader" },
          m = { name = "Mark" },
          h = { name = "History | Help | Highlight" },
          w = { name = "Workspace | LSP Action" },
          s = { name = "Spectre" },
        },
        c = { name = "Code" },
        d = { name = "DAP" },
        o = { name = "Orgmode" },
        m = { name = "Markdown | Format | Marks" },
        r = { name = "Rename | Rest" },
        s = { name = "Source | Session" },
        t = { name = "Translate" },
        w = { name = "Workspace" },
        g = { name = "Git" },
      }, { prefix = "<leader>" })
    end,
  },
  {
    "echasnovski/mini.bufremove",
    keys = {
      { "<leader>x", "<cmd>lua MiniBufremove.delete()<CR>", desc = "Buf Delete" },
    },
    version = "*",
    config = true,
  },
  {
    "echasnovski/mini.sessions",
    cond = not_vscode,
    lazy = true,
    priority = 100,
    event = "VimEnter",
    keys = {
      {
        "<leader>sw",
        '<cmd>:lua MiniSessions.write((vim.fn.getcwd():gsub("/", "_")))<CR>',
        desc = "Session Write",
      },
      {
        "<leader>sW",
        '<cmd>:lua MiniSessions.write((vim.fn.getcwd():gsub("/", "_")))',
        desc = "Session Write Custom",
      },
      { "<leader>ss", "<cmd>:lua MiniSessions.select()<CR>", desc = "Session Select" },
      {
        "<leader>sd",
        '<cmd>:lua MiniSessions.delete((vim.fn.getcwd():gsub("/", "_")))<CR>',
        desc = "Session Delete",
      },
    },
    version = "*",
    opts = function()
      local function shutdown_term()
        local terms = require("toggleterm.terminal")
        local terminals = terms.get_all()
        for _, terminal in pairs(terminals) do
          terminal:shutdown()
        end
      end
      return {
        directory = vim.fn.stdpath("state") .. "/sessions/",
        file = "session.vim",
        hooks = {
          -- Before successful action
          pre = { read = nil, write = shutdown_term, delete = nil },
          -- After successful action
          post = { read = nil, write = nil, delete = nil },
        },
      }
    end,
  },
}
