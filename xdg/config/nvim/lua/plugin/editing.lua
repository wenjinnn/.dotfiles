local not_vscode = require("util").not_vscode
return {
  {
    "tiagovla/scope.nvim",
    config = true,
    cond = not_vscode,
    event = "BufRead",
    keys = {
      {
        "<leader>mb",
        "<cmd>ScopeMoveBuf<cr>",
        desc = "Move Buf To Tab",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    cond = not_vscode,
    event = "BufRead",
    cmd = { "DiffFormat", "Format" },
    keys = function()
      local toggle_auto_format = function()
        vim.g.conform_autoformat = not vim.g.conform_autoformat
        local status
        if vim.g.conform_autoformat then
          status = "on"
        else
          status = "off"
        end
        vim.notify("Autoformat: " .. status)
      end

      return {
        {
          "<leader>mm",
          '<cmd>lua require"conform".format({async = true, lsp_fallback = true})<cr>',
          mode = { "n", "v" },
          desc = "Format",
        },
        {
          "<leader>md",
          "<cmd>DiffFormat<cr>",
          mode = { "n" },
          desc = "Diff Format",
        },
        {
          "<leader>mM",
          toggle_auto_format,
          mode = { "n", "v" },
          desc = "Auto Format Toggle",
        },
      }
    end,
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      vim.g.conform_autoformat = true
    end,
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
        },
        notify_on_error = false,
      })
      local diff_format = function()
        local buffer_readable = vim.fn.filereadable(vim.fn.bufname("%")) > 0
        if not vim.fn.has("git") or not vim.g.conform_autoformat or not buffer_readable then
          return
        end
        local filetype = vim.api.nvim_buf_get_option(0, "filetype")
        local format = require("conform").format
        -- stylua range format mass up indent, so use fall format for now
        if filetype == "lua" then
          format({
            lsp_fallback = true,
            timeout_ms = 500,
          })
          return
        end
        local filename = vim.fn.expand("%:p")
        local lines = vim.fn.system("git diff --unified=0 " .. filename):gmatch("[^\n\r]+")
        local ranges = {}
        for line in lines do
          if line:find("^@@") then
            local line_nums = line:match("%+.- ")
            if line_nums:find(",") then
              local _, _, first, second = line_nums:find("(%d+),(%d+)")
              table.insert(ranges, {
                start = { tonumber(first), 0 },
                ["end"] = { tonumber(first) + tonumber(second) + 1, 0 },
              })
            else
              local first = tonumber(line_nums:match("%d+"))
              table.insert(ranges, {
                start = { first, 0 },
                ["end"] = { first + 1, 0 },
              })
            end
          end
        end
        for _, range in pairs(ranges) do
          format({
            lsp_fallback = true,
            timeout_ms = 500,
            range = range,
          })
        end
      end
      vim.api.nvim_create_user_command("DiffFormat", diff_format, { desc = "Format changed lines" })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = diff_format,
        desc = "Auto Format changed lines",
      })
    end,
  },
  {
    "echasnovski/mini.comment",
    event = "BufRead",
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring").calculate_commentstring()
            or vim.bo.commentstring
        end,
      },
    },
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "echasnovski/mini.surround",
    event = "BufRead",
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    },
  },
  {
    "echasnovski/mini.splitjoin",
    event = "BufRead",
    opts = {},
  },
  {
    "echasnovski/mini.ai",
    event = "BufRead",
    opts = function()
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      return {
        custom_textobjects = {
          B = gen_ai_spec.buffer(),
          D = gen_ai_spec.diagnostic(),
          I = gen_ai_spec.indent(),
          L = gen_ai_spec.line(),
          N = gen_ai_spec.number(),
        },
      }
    end,
  },
  {
    "echasnovski/mini.align",
    event = "BufRead",
    opts = {},
  },
  {
    "echasnovski/mini.bracketed",
    event = "BufRead",
    opts = {
      treesitter = { suffix = "n", options = {} },
      comment = { suffix = "e", options = {} },
    },
  },
  {
    "echasnovski/mini.move",
    event = "BufRead",
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
          local configs = require("nvim-treesitter.configs")
          for name, fn in pairs(move) do
            if name:find("goto") == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find("[%]%[][cC]") then
                      vim.cmd("normal! " .. key)
                      return
                    end
                  end
                end
                return fn(q, ...)
              end
            end
          end
        end,
      },
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        config = function()
          require("ts_context_commentstring").setup({
            enable_autocmd = false,
          })
        end,
      },
      { "windwp/nvim-ts-autotag" },
      {
        "HiPhish/rainbow-delimiters.nvim",
        event = "BufRead",
        cond = not_vscode,
      },
    },
    build = ":TSUpdate",
    event = { "BufReadPre" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treeitter** module to be loaded in time.
      -- Luckily, the only thins that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
      vim.g.skip_ts_context_commentstring_module = true
    end,
    opts = {
      ensure_installed = {
        -- noice.nvim dependencies
        "vim",
        "regex",
        "markdown",
        "lua",
        "bash",
        "hurl",
        "markdown_inline",
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
      }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      ignore_install = {}, -- List of parsers to ignore installing
      auto_install = true,
      highlight = {
        enable = not_vscode, -- false will disable the whole extension
        additional_vim_regex_highlighting = false,
      },
      autotag = { enable = true },
      indent = { enable = true },
      autopairs = {
        enable = not_vscode,
      },
      textobjects = {
        select = {
          enable = true,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
          -- You can choose the select mode (default is charwise 'v')
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "V", -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
          },
          -- If you set this to `true` (default is `false`) then any textobject is
          -- extended to include preceding xor succeeding whitespace. Succeeding
          -- whitespace has priority in order to act similarly to eg the built-in
          -- `ap`.
          include_surrounding_whitespace = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        move = {
          enable = true,
        },
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
