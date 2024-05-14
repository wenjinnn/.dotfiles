local not_vscode = require("util").not_vscode

return {
  -- buffer | statusline | icon | treeview | startup buffer
  {
    "echasnovski/mini.starter",
    event = "VimEnter",
    cond = not_vscode,
    opts = function()
      local starter = require("mini.starter")
      return {
        items = {
          starter.sections.sessions(5, true),
          starter.sections.recent_files(5, true, true),
          starter.sections.recent_files(5, false, true),
          {
            name = "Agenda",
            action = "lua require'orgmode.api.agenda'.agenda()",
            section = "Org",
          },
          starter.sections.builtin_actions(),
        },
      }
    end,
  },
  { "kyazdani42/nvim-web-devicons", lazy = true },
  {
    "echasnovski/mini.notify",
    lazy = false,
    opts = {},
    keys = {
      {
        "<leader>n",
        "<cmd>lua MiniNotify.show_history()<CR>",
        desc = "Notify History",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "UIEnter",
    cond = not_vscode and not vim.g.started_by_firenvim,
    keys = {
      {
        "<leader>b",
        '<cmd>exe "LualineBuffersJump!" . v:count1<CR>',
        desc = "Lualine Buffers Jump",
      },
      {
        "<c-j>",
        '<cmd>exe "LualineBuffersJump!" . v:count1<CR>',
        desc = "Lualine Buffers Jump",
      },
      {
        "<leader>B",
        "<cmd>LualineBuffersJump $<CR>",
        desc = "Lualine Buffers Jump",
      },
    },
    opts = function()
      local navic = function()
        if not pcall(require, "nvim-navic") then
          return ""
        end
        local nvim_navic = require("nvim-navic")
        if not nvim_navic.is_available() then
          return ""
        end
        return nvim_navic.get_location()
      end
      return {
        options = {
          icons_enabled = true,
          theme = "auto",
          -- component_separators = { left = '', right = '' },
          -- component_separators = { left = '', right = '' },
          -- section_separators = { left = '', right = '' },
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 500,
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename", navic },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {
          lualine_a = {
            {
              "buffers",
              mode = 2,
              show_filename_only = true,
              hide_filename_extension = false,
              use_mode_colors = true,
            },
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = { { "windows", mode = 2, use_mode_colors = true } },
          lualine_y = { { "tabs", mode = 2, use_mode_colors = true } },
          lualine_z = {},
        },
        winbar = {},
        inactive_winbar = {},
        extensions = {
          "quickfix",
          "man",
          "toggleterm",
          "lazy",
          "fugitive",
        },
      }
    end,
  },
  {
    "chentoast/marks.nvim",
    cond = not_vscode,
    keys = {
      { "<leader>mt", "<cmd>MarksToggleSigns<cr>", desc = "Marks Toggle Signs" },
    },
    event = "BufRead",
    opts = {
      -- whether to map keybinds or not. default true
      default_mappings = true,
      -- which builtin marks to show. default {}
      builtin_marks = { ".", "<", ">", "^" },
      -- whether movements cycle back to the beginning/end of buffer. default true
      cyclic = true,
      -- whether the shada file is updated after modifying uppercase marks. default false
      force_write_shada = false,
      -- how often (in ms) to redraw signs/recompute mark positions.
      -- higher values will have better performance but may cause visual lag,
      -- while lower values may cause performance penalties. default 150.
      refresh_interval = 250,
      -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
      -- marks, and bookmarks.
      -- can be either a table with all/none of the keys, or a single number, in which case
      -- the priority applies to all marks.
      -- default 10.
      sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
      -- disables mark tracking for specific filetypes. default {}
      excluded_filetypes = {
        "null-ls-info",
        "TelescopePrompt",
        "rnvimr",
        "toggleterm",
        "minifiles",
        "minifiles-help",
        "tfm",
        "dap-repl",
        "dap-float",
        "Term",
        "lazygit",
        "lspinfo",
        "translate",
        "translator",
        "translatorborder",
        "translator_history",
        "glowpreview",
        "help",
        "zsh",
        "lazy",
        "org",
        "orghelp",
        "orgagenda",
        "httpResult",
        "dbee",
        "noice",
        "",
      },
      mappings = {},
      -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
      -- sign/virttext. Bookmarks can be used to group together positions and quickly move
      -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
      -- default virt_text is "".
      -- bookmark_0 = {
      --   sign = "⚑",
      --   virt_text = "hello world"
      -- },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    cond = not_vscode,
    lazy = true,
    keys = {
      { [[<c-\><c-\>]], desc = "ToggleTerm" },
      { "<leader>ft", "<cmd>TermSelect<cr>", desc = "Term Select" },
    },
    config = function()
      local get_height = function()
        return math.floor(vim.o.lines * 0.50)
      end
      local get_width = function()
        return math.floor(vim.o.columns * 0.80 - 1)
      end
      require("toggleterm").setup({
        -- size can be a number or function which is passed the current terminal
        size = get_height,
        open_mapping = [[<c-\><c-\>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_terminals = true,
        -- shading_factor = 1,       -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        autochdir = true, -- when neovim changes it current directory the terminal will change it's own when next it's opened
        terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
        -- persist_size = true,
        -- direction = 'float',
        close_on_exit = true, -- close the terminal window when the process exits
        shell = vim.o.shell, -- change the default shell
        float_opts = {
          width = get_width,
          height = get_height,
        },
        highlights = {
          -- highlights which map to a highlight group name and a table of it's values
          -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
          -- Normal = {
          --   link = 'Pmenu'
          -- },
          -- NormalFloat = {
          --   link = 'Pmenu'
          -- },
          -- FloatBorder = {
          --   link = 'Pmenu'
          -- },
        },
        winbar = {
          enabled = true,
          name_formatter = function(term) --  term: Terminal
            local buf_name = vim.api.nvim_buf_get_name(term.bufnr)
            if not buf_name then
              return term.name
            end
            local buf_len = string.len(buf_name)
            local colon_index = buf_name:match("^.*():")
            local slash_index = buf_name:match("^.*()/")
            local sub_index
            if colon_index then
              sub_index = colon_index
            elseif slash_index then
              sub_index = slash_index
            end
            if sub_index then
              buf_name = buf_name:sub(sub_index + 1, buf_len)
            end
            term.name = buf_name
            return buf_name
          end,
        },
      })
    end,
  },
  {
    "echasnovski/mini.indentscope",
    event = "BufRead",
    lazy = true,
    cond = not_vscode,
    opts = function()
      return {
        draw = {
          animation = require("mini.indentscope").gen_animation.none(),
        },
      }
    end,
  },
  {
    "echasnovski/mini.hipatterns",
    event = "BufRead",
    cond = not_vscode,
    opts = function()
      local hipatterns = require("mini.hipatterns")
      local hi_words = require("mini.extra").gen_highlighter.words
      return {
        highlighters = {
          fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
          hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
          todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
          note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      }
    end,
  },
}
