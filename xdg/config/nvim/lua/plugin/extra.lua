if vim.g.vscode then return end

local map = require("util").map
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- run code block in neovim
later(function()
  local build_sniprun = function(args)
    vim.system({ "sh", "./install.sh", "1" }, { cwd = args.path })
  end
  add({
    source = "michaelb/sniprun",
    hooks = {
      post_install = function(args) later(build_sniprun(args)) end,
      post_checkout = build_sniprun,
    },
  })

  require("sniprun").setup({
    repl_enable = { "Lua_nvim" },
    selected_interpreters = { "Lua_nvim" },
    live_mode_toggle = "enable",
  })
  map({ "n", "v" }, "<leader>rs", "<Plug>SnipRun", "Run snip")
  map("n", "<leader>rS", "<Plug>SnipRunOperator", "Run snip operator")
end)

later(function()
  -- ascii draw in neovim
  add("jbyuki/venn.nvim")
  map("v", "<leader>vv", ":VBox<cr>", "Draw a single line box or arrow")
  map("v", "<leader>vd", ":VBoxD<cr>", "Draw a double line box or arrow")
  map("v", "<leader>vh", ":VBoxH<cr>", "Draw a heavy line box or arrow")
  map("v", "<leader>vo", ":VBoxO<cr>", "Draw over a existing box or arrow")
  map("v", "<leader>vO", ":VBoxDO<cr>", "Draw over a doulbe line on a existing box or arrow")
  map("v", "<leader>vH", ":VBoxHO<cr>", "Draw over a heavy line on a existing box or arrow")
  map("v", "<leader>vf", ":VFill<cr>", "Draw fill a area with a solid color")
end)


-- http client
vim.filetype.add({ extension = { ["http"] = "http" } })
later(function()
  add("mistweaverco/kulala.nvim")
  local kulala = require("kulala")
  kulala.setup({
    display_mode = "float",
    winbar = true,
  })
  map("n", "<leader>re", kulala.run, "Execute request")
  map("n", "<leader>ra", kulala.run_all, "Execute all request")
  map("n", "<leader>rr", kulala.replay, "Replay last run request")
  map("n", "<leader>rt", kulala.show_stats, "Shows statistics of last request")
  map("n", "<leader>rp", kulala.scratchpad, "Opens scratchpad")
  map("n", "<leader>ri", kulala.inspect, "Inspect current request")
  map("n", "<leader>rv", kulala.toggle_view, "Toggle between body and headers")
  map("n", "<leader>rc", kulala.copy, "Copy current request as a curl command")
  map("n", "<leader>rf", kulala.search, "searches for http files")
  map("n", "<leader>rE", kulala.set_selected_env, "Sets selected environment")
  map("n", "<leader>rp", kulala.from_curl, "Paste curl from clipboard as http request")
  map("n", "[r", kulala.jump_prev, "Jump to previous request")
  map("n", "]r", kulala.jump_next, "Jump to next request")
end)

-- markdown, html, asciidoc, svg preview in browser
later(function()
  add("brianhuster/live-preview.nvim")
  map("n", "<leader>lp", "<cmd>LivePreview start<cr>", "Live preview start")
  map("n", "<leader>lP", "<cmd>LivePreview close<cr>", "Live preview close")
end)

-- neovim in browser
now(function()
  local install_firenvim_bin = function() vim.fn["firenvim#install"](0) end
  add({
    source = "glacambre/firenvim",
    hooks = {
      post_install = function() later(install_firenvim_bin) end,
      post_checkout = install_firenvim_bin,
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
    map("n", "<Esc><Esc>", "<Cmd>call firenvim#focus_page()<CR>", "Firenvim focus page")
  end
end)

-- db manage
later(function()
  add({
    source = "tpope/vim-dadbod",
    depends = {
      "kristijanhusak/vim-dadbod-completion",
      "kristijanhusak/vim-dadbod-ui",
    },
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
      map("x", "<leader>rq", "db#op_exec()", { expr = true, desc = "DB exec current query" })
    end,
  })
  map("n", "<leader>D", "<cmd>DBUIToggle<cr>", "DBUI toggle")
end)

-- search and replace tool
later(function()
  add("MagicDuck/grug-far.nvim")
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
      previewLocation = { n = "<localleader>Fi" },
      swapReplacementInterpreter = { n = "<localleader>Fx" },
      applyNext = { n = "<localleader>Fj" },
      applyPrev = { n = "<localleader>Fk" },
    },
  })
  local function grug_cursor_word()
    require("grug-far").grug_far({ prefills = { search = vim.fn.expand("<cword>") } })
  end
  local function grug_current_file()
    require("grug-far").grug_far({ prefills = { paths = vim.fn.expand("%") } })
  end
  map("n", "<leader>Fg", "<cmd>GrugFar<CR>", "Toggle GrugFar")
  map({ "n", "v" }, "<leader>Fv", grug_cursor_word, "GrugFar search current word")
  map("n", "<leader>Ff", grug_current_file, "Search on current file")
end)

-- AI related
later(function()
  -- official copilot plugin lua replacement
  add("wenjinnn/copilot.lua")
  require("copilot").setup({
    panel = { keymap = { open = "<M-j>" } },
    suggestion = {
      auto_trigger = true,
      hide_during_completion = false,
      keymap = { accept = "<M-CR>" },
    },
    filetypes = {
      ["dap-repl"] = false,
      ["*"] = true,
    },
  })

  -- AI chat workflow
  add("olimorris/codecompanion.nvim")
  local default_adapter = os.getenv("NVIM_AI_ADAPTER") or "copilot"
  local ollama_model = os.getenv("NVIM_OLLAMA_MODEL") or "deepseek-r1:14b"
  local api_key_cmd = "cmd:sops exec-env $SOPS_SECRETS 'echo -n $%s'";
  local ollama_setting = { schema = { model = { default = ollama_model } } }
  local function extend_adapter(adapter, key_or_set)
    local extend_set = key_or_set
    if type(key_or_set) == "string" then
      extend_set = {
        env = {
          api_key = api_key_cmd:format(key_or_set),
        },
      }
    end
    return function()
      return require("codecompanion.adapters").extend(adapter, extend_set)
    end
  end

  local function save_path()
    local Path = require("plenary.path")
    local p = Path:new(vim.fn.stdpath("data") .. "/codecompanion-chats")
    p:mkdir({ parents = true })
    return p
  end

  require("codecompanion").setup({
    adapters = {
      ollama = extend_adapter("ollama", ollama_setting),
      copilot = extend_adapter("copilot", {
        schema = { model = { default = "o3-mini-2025-01-31" } },
      }),
      githubmodels = extend_adapter("githubmodels", {
        schema = { model = { default = "o3-mini" } },
      }),
      anthropic = extend_adapter("anthropic", "ANTHROPIC_API_KEY"),
      deepseek = extend_adapter("deepseek", "DEEPSEEK_API_KEY"),
      siliconflow = extend_adapter("openai_compatible", {
        env = {
          url = "https://api.siliconflow.cn",
          api_key = api_key_cmd:format("SILICONFLOW_API_KEY"),
        },
        schema = { model = { default = "deepseek-ai/DeepSeek-R1" } },
      }),
    },
    strategies = {
      chat = {
        adapter = default_adapter,
        slash_commands = {
          buffer = { opts = { provider = "mini_pick" } },
          file = { opts = { provider = "mini_pick" } },
          help = { opts = { provider = "mini_pick" } },
          symbols = { opts = { provider = "mini_pick" } },
        },
        keymaps = {
          send = { modes = { n = { "<C-s>" } } },
          completion = { modes = { i = "<C-n>" } },
          save = {
            modes = { n = "gS" },
            index = 99,
            callback = function()
              -- Save the current codecompanion.nvim chat buffer to a file in the save_folder.
              local save_name = os.date("%Y-%m-%d_%H:%M:%S") .. ".md"
              local save_file = save_path():joinpath(save_name)
              local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
              save_file:write(table.concat(lines, "\n"), "w")
            end,
            description = "Save Chat",
          },
        },
      },
      inline = { adapter = default_adapter },
      cmd = { adapter = default_adapter },
    },
    display = {
      chat = { window = { width = 0.33 } },
      diff = { provider = "mini_diff" },
    },
  })

  -- modified from https://github.com/fredrikaverpil/dotfiles/blob/49a860e7ca7bc6eabe24d8eadf92764a03c5d59d/nvim-fredrik/lua/fredrik/plugins/codecompanion.lua
  -- Load a saved codecompanion.nvim chat file into a new CodeCompanion chat buffer.
  -- Usage: CodeCompanionLoad
  vim.api.nvim_create_user_command("CodeCompanionLoad", function()
    local files = vim.fn.glob(save_path() .. "/*", false, true)
    local current_win
    MiniPick.start({
      source = {
        name = "Saved CodeCompanion Chats | <choose_marked>: remove",
        items = files,
        choose = function(item)
          if not item then
            return
          end
          print(vim.inspect(item))
          -- Open new CodeCompanion chat with default adapter
          vim.cmd("CodeCompanionChat")
          -- Read contents of saved chat file
          local lines = vim.fn.readfile(item)
          -- Get the current buffer (which should be the new CodeCompanion chat)
          local current_buf = vim.api.nvim_get_current_buf()
          current_win = vim.api.nvim_get_current_win()
          -- Paste contents into the new chat buffer
          vim.api.nvim_buf_set_lines(current_buf, 0, -1, false, lines)
          vim.api.nvim_set_current_win(current_win)
        end,
        choose_marked = function(items)
          for _, file in ipairs(items) do
            os.remove(file)
          end
        end,
      },
    })
    if current_win then
      vim.api.nvim_set_current_win(current_win)
    end
  end, { desc = "Load saved CodeCompanion chat" })

  map("n", "<leader>Cl", "<cmd>CodeCompanionLoad<cr>", "Load a Code companion chat")
  map({ "n", "v" }, "<leader>Ca", "<cmd>CodeCompanionActions<cr>", "Code companion actions")
  map({ "n", "v" }, "<leader>CC", "<cmd>CodeCompanionChat Toggle<cr>", "Code companion chat")
  map("v", "<leader>CA", "<cmd>CodeCompanionChat Add<cr>", "Code companion chat add")
  -- Expand 'cc' into 'CodeCompanion' in the command line
  vim.cmd([[cab cc CodeCompanion]])
end)
