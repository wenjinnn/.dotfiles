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
        vim.notify("Autoformat: " .. vim.g.conform_autoformat and "on" or "off")
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
      require("conform").setup({})
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
        add = "ys", -- Add surrounding in Normal and Visual modes
        delete = "ds", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "cs", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    },
    config = function(_, opts)
      require("mini.surround").setup(opts)
      -- make mini.surround behavior like vim-surround
      -- Remap adding surrounding to Visual mode selection
      vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

      -- Make special mapping for "add surrounding for line"
      vim.keymap.set('n', 'yss', 'ys_', { remap = true })
    end
  },
  {
    "echasnovski/mini.splitjoin",
    event = "BufRead",
    opts = function()
      local gen_hook = require("mini.splitjoin").gen_hook
      local curly = { brackets = { '%b{}' } }
      -- Add trailing comma when splitting inside curly brackets
      local add_comma_curly = gen_hook.add_trailing_separator(curly)

      -- Delete trailing comma when joining inside curly brackets
      local del_comma_curly = gen_hook.del_trailing_separator(curly)

      -- Pad curly brackets with single space after join
      local pad_curly = gen_hook.pad_brackets(curly)
      return {
        split = { hooks_post = { add_comma_curly } },
        join = { hooks_post = { del_comma_curly, pad_curly } },
      }
    end,
  },
  {
    "echasnovski/mini.ai",
    event = "BufRead",
    opts = function()
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      local gen_spec = require("mini.ai").gen_spec
      return {
        custom_textobjects = {
          B = gen_ai_spec.buffer(),
          D = gen_ai_spec.diagnostic(),
          I = gen_ai_spec.indent(),
          L = gen_ai_spec.line(),
          N = gen_ai_spec.number(),
          -- Tweak argument to be recognized only inside `()` between `;`
          a = gen_spec.argument({ brackets = { '%b()' }, separator = ';' }),
          -- Tweak function call to not detect dot in function name
          f = gen_spec.function_call({ name_pattern = '[%w_]' }),
          -- Function definition (needs treesitter queries with these captures)
          -- This need nvim-treesitter-textobjects, see https://github.com/echasnovski/mini.nvim/issues/947#issuecomment-2154242659
          F = gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
          -- Make `|` select both edges in non-balanced way
          o = gen_spec.treesitter({
            a = { '@conditional.outer', '@loop.outer' },
            i = { '@conditional.inner', '@loop.inner' },
          }),
          c = gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
          ['|'] = gen_spec.pair('|', '|', { type = 'non-balanced' }),
        },
        n_lines = 500,
      }
    end,
  },
  {
    "echasnovski/mini.align",
    event = "BufRead",
    opts = {
      mappings = {
        start = "<leader>a",
        start_with_preview = "<leader>A",
      },
    },
  },
  {
    "echasnovski/mini.bracketed",
    event = "BufRead",
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter",
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
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects" },
      { "nvim-treesitter/nvim-treesitter-context" },
      { "windwp/nvim-ts-autotag", opts = {} },
      { "JoosepAlviste/nvim-ts-context-commentstring", opts = { enable_autocmd = false } },
      { "hiphish/rainbow-delimiters.nvim" },
    },
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
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    main = "nvim-treesitter.configs",
  },
}
