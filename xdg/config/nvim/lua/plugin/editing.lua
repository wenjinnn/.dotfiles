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
          "<leader>mm",
          '<cmd>lua require"conform".format({async = true, lsp_fallback = true})<cr>',
          mode = { "n", "v" },
          desc = "Format",
        },
        {
          "<leader>mM",
          toggle_auto_format,
          mode = { "n", "v" },
          desc = "Auto Format Toggle",
        },
      }
    end,
    config = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      vim.g.conform_autoformat = true
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

      vim.api.nvim_create_autocmd("BufLeave", {
        pattern = "*",
        callback = function()
          local buffer_readable = vim.fn.filereadable(vim.fn.bufname("%")) > 0
          local buffer_changed = vim.fn.getbufinfo("%")[1].changed > 0
          if not vim.bo.readonly and buffer_readable and buffer_changed then
            diff_format()
            vim.cmd("update")
          end
        end,
        desc = "Auto Format changed lines",
      })
    end,
  },
  {
    "kylechui/nvim-surround",
    event = "BufRead",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "gs",
          normal_cur = "gss",
          normal_line = "gS",
          normal_cur_line = "gSS",
          visual = "gs",
          visual_line = "gS",
          delete = "gsd",
          change = "gsc",
          change_line = "gsC",
        },
      })
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = "BufRead",
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
  {
    "echasnovski/mini.splitjoin",
    keys = { { "gsj", desc = "Splitjoin" } },
    config = function()
      require("mini.splitjoin").setup({
        mappings = {
          toggle = "gsj",
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects" },
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        config = function()
          vim.g.skip_ts_context_commentstring_module = true
          require("ts_context_commentstring").setup({
            enable_autocmd = false,
          })
        end,
      },
      { "windwp/nvim-ts-autotag" },
      {
        "windwp/nvim-autopairs",
        opts = { check_ts = true },
      },
    },
    build = ":TSUpdate",
    event = { "BufReadPre" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    cond = not_vscode,
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treeitter** module to be loaded in time.
      -- Luckily, the only thins that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    opts = {
      autotag = {
        enable = true,
        filetypes = {
          "html",
          "javascript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "xml",
        },
      },
      ensure_installed = {}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      ignore_install = {}, -- List of parsers to ignore installing
      auto_install = true,
      highlight = {
        enable = true, -- false will disable the whole extension
      },
      indent = { enable = true },
      autopairs = {
        enable = true,
      },
      rainbow = {
        enable = true,
        extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
        -- max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
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
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
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
