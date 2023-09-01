return {
  {
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup({
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
    end
  },
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup({
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
      { 'JoosepAlviste/nvim-ts-context-commentstring' },
      { 'HiPhish/rainbow-delimiters.nvim' },
      { 'windwp/nvim-ts-autotag' },
      { 'windwp/nvim-autopairs',                      opts = { check_ts = true } },
    },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        autotag = {
          enable = true,
          filetypes = {
            'html', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'xml'
          },
        },
        ensure_installed = 'all',    -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        ignore_install = {},         -- List of parsers to ignore installing
        highlight = {
          enable = not vim.g.vscode, -- false will disable the whole extension
          disable = {}               -- list of language that will be disabled
        },
        autopairs = {
          enable = true
        },
        rainbow = {
          enable = not vim.g.vscode,
          extended_mode = true -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
          -- max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
        },
        refactor = {
          highlight_definitions = {
            enable = false,
            -- Set to false if you have an `updatetime` of ~100.
            clear_on_cursor_move = false
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
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
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
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'V',  -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding xor succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            include_surrounding_whitespace = true,
          },
        },
      })
    end
  }
}
