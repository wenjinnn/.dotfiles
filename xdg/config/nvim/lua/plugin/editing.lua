local not_vscode = require("util").not_vscode
return {
  {
    "stevearc/conform.nvim",
    cond = not_vscode,
    event = "BufRead",
    cmd = { "DiffFormat", "Format" },
    keys = {
      {
        "<leader>mm",
        '<cmd>lua require"conform".format({async = true, lsp_fallback = true})<cr>',
        mode = { "n", "v" },
        desc = "Format",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
        },
      })
      local diff_format = function()
        if not vim.fn.has("git") then
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
                ["end"] = { tonumber(first) + tonumber(second), 0 },
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
        local format = require("conform").format
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
      ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      ignore_install = {}, -- List of parsers to ignore installing
      highlight = {
        enable = true, -- false will disable the whole extension
        disable = {}, -- list of language that will be disabled
      },
      autopairs = {
        enable = true,
      },
      rainbow = {
        enable = true,
        extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
        -- max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
      },
      refactor = {
        highlight_definitions = {
          enable = false,
          -- Set to false if you have an `updatetime` of ~100.
          clear_on_cursor_move = false,
        },
        highlight_current_scope = { enable = true },
        smart_rename = {
          enable = true,
          keymaps = {
            smart_rename = "gR",
          },
        },
        navigation = {
          enable = true,
          keymaps = {
            goto_definition = "gnd",
            list_definitions = "gnD",
            list_definitions_toc = "gO",
            goto_next_usage = "<a-*>",
            goto_previous_usage = "<a-#>",
          },
        },
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
      },
    },
  },
}
