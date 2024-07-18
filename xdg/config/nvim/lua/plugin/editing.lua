local not_vscode = require("util").not_vscode
return {
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
          mode = { "n", "v" },
          "<leader>mm",
          '<cmd>lua require"conform".format({async = true, lsp_fallback = true})<cr>',
          desc = "Format",
        },
        { "<leader>md", "<cmd>DiffFormat<cr>", desc = "Diff format" },
        { "<leader>mM", toggle_auto_format, desc = "Auto format toggle" },
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
      })
      local range_ignore_filetypes = { "lua" }
      local diff_format = function()
        local data = MiniDiff.get_buf_data()
        if not data or not data.hunks or not vim.g.conform_autoformat then
          vim.notify("No hunks in this buffer or auto format is currently disabled")
          return
        end
        local format = require("conform").format
        -- stylua range format mass up indent, so use full format for now
        if vim.tbl_contains(range_ignore_filetypes, vim.bo.filetype) then
          format({ lsp_fallback = true, timeout_ms = 500 })
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
          format({ lsp_fallback = true, timeout_ms = 500, range = range })
        end
      end
      vim.api.nvim_create_user_command("DiffFormat", diff_format, { desc = "Format changed lines" })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = diff_format,
        desc = "Auto format changed lines",
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    cond = not_vscode,
    event = "BufRead",
    config = function()
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
    end,
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
      { "nvim-treesitter/nvim-treesitter-context" },
      { "windwp/nvim-ts-autotag", opts = {} },
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        opts = { enable_autocmd = false },
      },
      { "hiphish/rainbow-delimiters.nvim" },
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
      local get_option = vim.filetype.get_option
      -- FIX native comment not work for jsx or vue template, relate issue: https://github.com/neovim/neovim/issues/28830
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.filetype.get_option = function(filetype, option)
        return option == "commentstring"
            and require("ts_context_commentstring.internal").calculate_commentstring()
          or get_option(filetype, option)
      end
    end,
    opts = {
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
      }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      ignore_install = { "org" }, -- List of parsers to ignore installing
      auto_install = true,
      highlight = {
        enable = not_vscode, -- false will disable the whole extension
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
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
