local not_vscode = require("util").not_vscode
return {
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
    build = function()
      vim.fn["firenvim#install"](0)
    end,
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
            "<C-m>",
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
      { "<leader><leader>d", "<cmd>DBUIToggle<cr>", desc = "DBUI toggle" },
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
        "<leader>st",
        '<cmd>lua require("spectre").toggle()<CR>',
        desc = "Toggle spectre",
      },
      {
        "<leader>sv",
        '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
        mode = { "n", "v" },
        desc = "Spectre search current word",
      },
      {
        "<leader>sf",
        '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
        desc = "Search on current file",
      },
    },
  },
  {
    "uga-rosa/translate.nvim",
    cmd = "Translate",
    keys = {
      -- Display translation in a window
      { "<leader>tt", "<cmd>Translate ZH<CR>", mode = { "n", "x" }, desc = "Translate to a pop window" },
      -- Replace the text with translation
      { "<leader>tr", "<cmd>Translate ZH -output=replace<CR>", mode = { "n", "x" }, desc = "Translate and replace" },
      -- Insert the text with translation
      { "<leader>ti", "<cmd>Translate ZH -output=insert<CR>", mode = { "n", "x" }, desc = "Translate and insert word" },
      -- copy translation to register
      { "<leader>ty", "<cmd>Translate ZH -output=register<CR>", mode = { "n", "x" }, desc = "Translate to register" },
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
    event = "BufRead",
    cond = not_vscode,
    opts = function()
      local miniclue = require("mini.clue")
      local z_post_keys = { zl = "z", zh = "z", zL = "z", zH = "z" }
      local clue_z_keys = miniclue.gen_clues.z()
      for _, v in ipairs(clue_z_keys) do
        for key, postkeys in pairs(z_post_keys) do
          if v.keys == key then
            v.postkeys = postkeys
          end
        end
      end
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
          -- Operator-pending mode key
          { mode = "o", keys = "a" },
          { mode = "o", keys = "i" },
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
          clue_z_keys,
        },
      }
    end,
  },
  {
    "echasnovski/mini.bufremove",
    keys = {
      { "<leader>x", "<cmd>lua MiniBufremove.delete()<CR>", desc = "Buf delete" },
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
        { "<leader>sw", write_session, desc = "Session write" },
        {
          "<leader>sW",
          function()
            MiniSessions.write(vim.fn.input("Session name: "))
          end,
          desc = "Session write custom",
        },
        { "<leader>sd", delete_session, desc = "Session delete" },
        {
          "<leader>sD",
          function()
            MiniSessions.delete(vim.fn.input("Session name: "))
          end,
          desc = "Session delete custom",
        },
      }
    end,
    opts = function()
      return {
        directory = vim.fn.stdpath("state") .. "/sessions/",
        file = "session.vim",
        -- Whether to force possibly harmful actions (meaning depends on function)
        force = { read = false, write = true, delete = true },
        hooks = {
          -- Before successful action
          pre = { read = nil, write = nil, delete = nil },
          -- After successful action
          post = { read = require("util").delete_dap_terminals, write = nil, delete = nil },
        },
      }
    end,
  },
}
