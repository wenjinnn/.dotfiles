local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local map = require("util").map

-- textobject enhancement
later(function()
  local gen_ai_spec = require("mini.extra").gen_ai_spec
  local gen_spec = require("mini.ai").gen_spec
  require("mini.ai").setup({
    custom_textobjects = {
      B = gen_ai_spec.buffer(),
      D = gen_ai_spec.diagnostic(),
      I = gen_ai_spec.indent(),
      L = gen_ai_spec.line(),
      N = gen_ai_spec.number(),
      -- Tweak argument to be recognized only inside `()` between `;`
      a = gen_spec.argument({ brackets = { "%b()" }, separator = ";" }),
      -- Tweak function call to not detect dot in function name
      f = gen_spec.function_call({ name_pattern = "[%w_]" }),
      -- Function definition (needs treesitter queries with these captures)
      -- This need nvim-treesitter-textobjects, see https://github.com/echasnovski/mini.nvim/issues/947#issuecomment-2154242659
      F = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
      -- Make `|` select both edges in non-balanced way
      o = gen_spec.treesitter({
        a = { "@conditional.outer", "@loop.outer" },
        i = { "@conditional.inner", "@loop.inner" },
      }),
      c = gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
      ["|"] = gen_spec.pair("|", "|", { type = "non-balanced" }),
    },
    n_lines = 500,
  })
end)

-- customize mini.splitjoin
later(function()
  local gen_hook = require("mini.splitjoin").gen_hook
  local curly = { brackets = { "%b{}" } }
  -- Add trailing comma when splitting inside curly brackets
  local add_comma_curly = gen_hook.add_trailing_separator(curly)
  -- Delete trailing comma when joining inside curly brackets
  local del_comma_curly = gen_hook.del_trailing_separator(curly)
  -- Pad curly brackets with single space after join
  local pad_curly = gen_hook.pad_brackets(curly)
  require("mini.splitjoin").setup({
    split = { hooks_post = { add_comma_curly } },
    join = { hooks_post = { del_comma_curly, pad_curly } },
  })
end)

-- setup mini.surround and disable original `s` functionality to reduce key wait time
later(function()
  require("mini.surround").setup()
  vim.keymap.set({ "n", "x" }, "s", "<Nop>")
end)

-- treesitter related
later(function()
  add({
    source = "nvim-treesitter/nvim-treesitter",
    depends = {
      "windwp/nvim-ts-autotag",
      "hiphish/rainbow-delimiters.nvim",
      "nvim-treesitter/nvim-treesitter-context",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    hooks = {
      post_checkout = function() vim.cmd("TSUpdate") end,
    },
  })
  -- fix nvim-treesitter-textobjects occur an error when add it to nvim-treesitter depends
  later(function()
    add({ source = "nvim-treesitter/nvim-treesitter-textobjects" })
  end)
  vim.g.skip_ts_context_commentstring_module = true
  local get_option = vim.filetype.get_option
  -- FIX native comment not work for jsx or vue template, relate issue: https://github.com/neovim/neovim/issues/28830
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.filetype.get_option = function(filetype, option)
    return option == "commentstring"
        and require("ts_context_commentstring.internal").calculate_commentstring()
        or get_option(filetype, option)
  end
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      -- basic
      "vim",
      "vimdoc",
      "regex",
      "markdown",
      "lua",
      "luadoc",
      "luap",
      "query",
      "bash",
      "hurl",
      "diff",
      "markdown_inline",
      "make",
      -- autotag dependencies
      "astro",
      "glimmer",
      "html",
      "javascript",
      "markdown",
      "php",
      "svelte",
      "tsx",
      "typescript",
      "vue",
      "xml",
      -- personal frequently used
      "nix",
      "java",
      "rust",
      "sql",
      "css",
      "scss",
      "yaml",
    }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = { "org" }, -- List of parsers to ignore installing
    auto_install = true,
    highlight = {
      enable = not vim.g.vscode, -- false will disable the whole extension
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
  })
  require("ts_context_commentstring").setup({
    enable_autocmd = false,
  })
  require("nvim-ts-autotag").setup()
  local function go_to_context()
    require("treesitter-context").go_to_context(vim.v.count1)
  end
  map("n", "[e", go_to_context, "treesitter context upward")
end)

later(function()
  require("mini.align").setup()
  require("mini.bracketed").setup()
  require("mini.pairs").setup()
end)

-- we don't need below plugins in vscode
if vim.g.vscode then return end

-- customize mini.sessions setup
now(function()
  require("mini.sessions").setup({
    -- Whether to force possibly harmful actions (meaning depends on function)
    force = { read = false, write = true, delete = true },
    hooks = {
      -- Before successful action
      pre = { read = nil, write = nil, delete = nil },
      -- After successful action
      post = { read = require("util").delete_dap_terminals, write = nil, delete = nil },
    },
  })
  local session_name = function()
    local cwd = vim.fn.getcwd()
    local parent_path = vim.fn.fnamemodify(cwd, ":h")
    local current_tail_path = vim.fn.fnamemodify(cwd, ":t")
    return string.format("%s@%s", current_tail_path, parent_path:gsub("/", "-"))
  end
  local function session_write()
    require("mini.sessions").write(session_name())
  end
  local function session_write_custom()
    MiniSessions.write(vim.fn.input("Session name: "))
  end
  local function session_delete()
    require("mini.sessions").delete(session_name())
  end
  local function session_delete_custom()
    MiniSessions.delete(vim.fn.input("Session name: "))
  end
  map("n", "<leader>sw", session_write, "Session write")
  map("n", "<leader>sW", session_write_custom, "Session write custom")
  map("n", "<leader>sd", session_delete, "Session delete")
  map("n", "<leader>sD", session_delete_custom, "Session delete custom")
  map("n", "<leader>ss", MiniSessions.select, "Session select")
end)

later(function()
  require("mini.bufremove").setup()
  map("n", "<leader>x", "<cmd>lua MiniBufremove.delete()<CR>", "Buf delete")
end)

-- basic lint setup
later(function()
  add("mfussenegger/nvim-lint")
  local lint = require("lint")
  -- just use the default lint
  -- TODO maybe add more linter in future
  lint.linters_by_ft = {}
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    callback = function()
      lint.try_lint()
      lint.try_lint("compiler")
    end,
  })
end)

-- conform with some auto format setting
later(function()
  add("stevearc/conform.nvim")
  require("conform").setup({
    formatters_by_ft = {
      nix = { "alejandra" },
    },
  })
  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  vim.g.conform_autoformat = true
  local diff_format = function()
    local data = MiniDiff.get_buf_data()
    if not data or not data.hunks or not vim.g.conform_autoformat then
      vim.notify("No hunks in this buffer or auto format is currently disabled")
      return
    end
    local ranges = {}
    for _, hunk in pairs(data.hunks) do
      if hunk.type ~= "delete" then
        -- always insert to index 1 so format below could start from last hunk, which this sort didn't mess up range
        table.insert(ranges, 1, {
          start = { hunk.buf_start, 0 },
          ["end"] = { hunk.buf_start + hunk.buf_count, 0 },
        })
      end
    end
    for _, range in pairs(ranges) do
      require("conform").format({ lsp_fallback = true, timeout_ms = 500, range = range })
    end
  end
  vim.api.nvim_create_user_command("DiffFormat", diff_format, { desc = "Format changed lines" })
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = diff_format,
    desc = "Auto format changed lines",
  })
  local function code_format()
    require("conform").format({ async = true, lsp_fallback = true })
  end
  local function auto_format_toggle()
    vim.g.conform_autoformat = not vim.g.conform_autoformat
      vim.notify("Autoformat: " .. (vim.g.conform_autoformat and "on" or "off"))
  end
  map({ "n", "v" }, "<leader>cm", code_format, "Format")
  map("n", "<leader>cM", auto_format_toggle, "Auto format toggle")
end)

-- completion and snippets
later(function()
  require("mini.completion").setup({
    window = {
      info = { border = "solid" },
      signature = { border = "solid" },
    },
    set_vim_settings = false,
  })

  local keycode = vim.keycode or require("util").keycode

  local keys = {
    ["cr"] = keycode("<CR>"),
    ["ctrl-y"] = keycode("<C-y>"),
    ["ctrl-y_cr"] = keycode("<C-y><CR>"),
  }

  local function cr_action()
    if vim.fn.pumvisible() ~= 0 then
      -- If popup is visible, confirm selected item or add new line otherwise
      local item_selected = vim.fn.complete_info()["selected"] ~= -1
      return item_selected and keys["ctrl-y"] or keys["ctrl-y_cr"]
    else
      return require("mini.pairs").cr()
    end
  end

  map("i", "<CR>", cr_action, { expr = true })

  add("rafamadriz/friendly-snippets")
  local gen_loader = require("mini.snippets").gen_loader
  local snippets_path = vim.fn.stdpath("config") .. "/snippets"
  require("mini.snippets").setup({
    snippets = {
      -- Load custom file with global snippets first
      -- For variables in snippets json, see https://code.visualstudio.com/docs/editor/userdefinedsnippets
      gen_loader.from_file(snippets_path .. "/global.json"),
      -- Load snippets based on current language by reading files from
      -- "snippets/" subdirectories from 'runtimepath' directories.
      gen_loader.from_lang(),
      -- Load project-local snippets with `gen_loader.from_file()`
      -- and relative path (file doesn't have to be present)
      gen_loader.from_file(".vscode/project.code-snippets"),

      -- Custom loader for language-specific project-local snippets
      function(context)
        local rel_path = ".vscode/" .. context.lang .. ".code-snippets"
        if vim.fn.filereadable(rel_path) == 0 then return end
        return MiniSnippets.read_file(rel_path)
      end,
    },
  })

  add("chrisgrieser/nvim-scissors")
  require("scissors").setup({
    snippetDir = snippets_path,
    jsonFormatter = "jq",
    backdrop = { enabled = false },
  })
  map("n", "<leader>cS", "<cmd>ScissorsEditSnippet<cr>", "Snippet edit")
  map({ "n", "x" }, "<leader>cs", "<cmd>ScissorsAddNewSnippet<cr>", "Snippet add")

  add({
    source = "echasnovski/neogen",
    checkout = "mini-snippets",
  })
  require("neogen").setup({ snippet_engine = "mini" })
  map("n", "<leader>cA", "<cmd>Neogen<cr>", "Generate annotation")
end)
