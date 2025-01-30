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


vim.filetype.add({ extension = { ["http"] = "http" } })
-- http client
later(function()
  add("mistweaverco/kulala.nvim")
  require("kulala").setup({
    display_mode = "float",
    winbar = true,
  })
  map("n", "<leader>re", "<cmd>lua require('kulala').run()<cr>", "Execute request")
  map("n", "<leader>ra", "<cmd>lua require('kulala').run_all()<cr>", "Execute all request")
  map("n", "<leader>rr", "<cmd>lua require('kulala').replay()<cr>", "Replay last run request")
  map("n", "<leader>rt", "<cmd>lua require('kulala').show_stats()<cr>", "Shows statistics of the last run request")
  map("n", "<leader>rp", "<cmd>lua require('kulala').scratchpad()<cr>", "Opens scratchpad")
  map("n", "<leader>ri", "<cmd>lua require('kulala').inspect()<cr>", "Inspect current request")
  map("n", "<leader>rv", "<cmd>lua require('kulala').toggle_view()<cr>", "Toggle between body and headers")
  map("n", "<leader>rc", "<cmd>lua require('kulala').copy()<cr>", "Copy current request as a curl command")
  map("n", "<leader>rf", "<cmd>lua require('kulala').search()<cr>", "searches for http files")
  map("n", "<leader>rE", "<cmd>lua require('kulala').set_selected_env()<cr>", "Sets selected environment")
  map("n", "<leader>rp", "<cmd>lua require('kulala').from_curl()<cr>", "Paste curl from clipboard as http request")
  map("n", "[r", "<cmd>lua require('kulala').jump_prev()<cr>", "Jump to previous request")
  map("n", "]r", "<cmd>lua require('kulala').jump_next()<cr>", "Jump to next request")
end)
-- markdown preview in browser
later(function()
  local install_markdown_preview_bin = function() vim.fn["mkdp#util#install"]() end
  add({
    source = "iamcco/markdown-preview.nvim",
    hooks = {
      post_install = function() later(install_markdown_preview_bin) end,
      post_checkout = install_markdown_preview_bin,
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
  map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", "Markdown preview toggle")
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

-- AI companion
later(function()
  add("olimorris/codecompanion.nvim")
  local adapter = os.getenv("NVIM_AI_ADAPTER") or "ollama"
  local ollama_model = os.getenv("NVIM_OLLAMA_MODEL") or "llama3.2-vision:latest"
  require("codecompanion").setup({
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = "cmd:sops exec-env $SOPS_SECRETS 'echo -n $ANTHROPIC_API_KEY'",
          },
        })
      end,
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          schema = {
            model = {
              default = ollama_model,
            },
          },
        })
      end,
      deepseek = function()
        return require("codecompanion.adapters").extend("deepseek", {
          env = {
            api_key = "cmd:sops exec-env $SOPS_SECRETS 'echo -n $DEEPSEEK_API_KEY'",
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = adapter,
        slash_commands = {
          help = {
            opts = {
              provider = "mini_pick",
            },
          },
        },
      },
      inline = { adapter = adapter },
      agent = { adapter = adapter },
    },
    display = {
      chat = {
        show_settings = true,
      },
      diff = {
        provider = "mini_diff",
      },
    },
  })
  map({ "n", "v" }, "<leader>Ca", "<cmd>CodeCompanionActions<cr>", "Code companion actions")
  map({ "n", "v" }, "<leader>CC", "<cmd>CodeCompanionChat Toggle<cr>", "Code companion chat")
  map("v", "<leader>CA", "<cmd>CodeCompanionChat Add<cr>", "Code companion chat add")
  -- Expand 'cc' into 'CodeCompanion' in the command line
  vim.cmd([[cab cc CodeCompanion]])
end)
