local not_vscode = require("util").not_vscode
return {
  -- rest client
  {
    "jellydn/hurl.nvim",
    cond = not_vscode,
    ft = "hurl",
    lazy = true,
    opts = {
      mode = "popup",
      show_notification = true,
      env_file = {
        ".envrc",
        ".env",
        "vars.env",
        "hurl.env",
      },
    },
    init = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.hurl",
        callback = function()
          vim.bo.filetype = "hurl"
        end,
      })
    end,
    keys = {
      -- Run API request
      { "<leader>rA", "<cmd>HurlRunner<CR>", desc = "Run All requests" },
      { "<leader>ra", "<cmd>HurlRunnerAt<CR>", desc = "Run Api request" },
      { "<leader>re", "<cmd>HurlRunnerToEntry<CR>", desc = "Run Api request to entry" },
      { "<leader>rt", "<cmd>HurlToggleMode<CR>", desc = "Hurl Toggle Mode" },
      { "<leader>rv", "<cmd>HurlVerbose<CR>", desc = "Run Api in verbose mode" },
      -- Run Hurl request in visual mode
      { "<leader>ra", ":HurlRunner<CR>", desc = "Hurl Runner", mode = "v" },
    },
  },
  {
    "nvim-orgmode/orgmode",
    cond = not_vscode,
    event = "BufReadPre",
    opts = function()
      local config = {
        org_agenda_files = { "~/project/my/archive/org/*" },
        win_split_mode = "float",
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
    cond = not_vscode,
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
            "<C-m>",
            "db#op_exec()",
            { expr = true, desc = "DB Exec Current Query" }
          )
        end,
      })
    end,
    dependencies = {
      { "tpope/vim-dadbod" },
    },
    keys = {
      { "<leader><leader>d", "<cmd>DBUIToggle<cr>", desc = "DBUI Toggle" },
      { "<leader>e", "db#op_exec()", mode = { "n", "x" }, desc = "DB Exec" },
    },
    ft = { "sql", "mysql", "plsql" },
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
    "echasnovski/mini.clue",
    event = "VeryLazy",
    cond = not_vscode,
    opts = function()
      local miniclue = require("mini.clue")
      return {
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- `g` key
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },

          { mode = "n", keys = "g" },
          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },

          -- mini.bracketed
          { mode = "n", keys = "]" },
          { mode = "n", keys = "[" },

          { mode = "n", keys = "\\" },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows({
            submode_resize = true,
          }),
          miniclue.gen_clues.z(),
        },
      }
    end,
  },
  {
    "echasnovski/mini.bufremove",
    keys = {
      { "<leader>x", "<cmd>lua MiniBufremove.delete()<CR>", desc = "Buf Delete" },
    },
    version = "*",
    cond = not_vscode,
    config = true,
  },
  {
    "echasnovski/mini.sessions",
    cond = not_vscode,
    lazy = true,
    priority = 100,
    event = "VimEnter",
    keys = function()
      local session_name = function()
        local cwd = vim.fn.getcwd()
        local parent_path = vim.fn.fnamemodify(cwd, ":h")
        local current_tail_path = vim.fn.fnamemodify(cwd, ":t")
        return string.format("%s@%s", current_tail_path, parent_path:gsub("/", "-"))
      end
      local write_session = function()
        require("mini.sessions").write(session_name())
      end
      local delete_session = function()
        require("mini.sessions").delete(session_name())
      end
      return {
        { "<leader>sw", write_session, desc = "Session Write" },
        { "<leader>sW", ":lua MiniSessions.write()", desc = "Session Write Custom" },
        { "<leader>sd", delete_session, desc = "Session Delete" },
      }
    end,
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
        -- Whether to force possibly harmful actions (meaning depends on function)
        force = { read = false, write = true, delete = true },
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
