local not_vscode = require("util").not_vscode
return {
  {
    "nvim-telescope/telescope.nvim",
    cond = not_vscode,
    event = "BufRead",
    cmd = "Telescope",
    keys = {
      -- for mason filter
      { "<leader>L", "<cmd>Mason<CR>", desc = "Mason" },
      { "gd", "<cmd>Telescope lsp_definitions<CR>", desc = "Telescope Lsp Definitions" },
      {
        "gi",
        "<cmd>Telescope lsp_implementations<CR>",
        desc = "Telescope Lsp Implementations",
      },
      {
        "gI",
        "<cmd>Telescope lsp_incoming_calls<CR>",
        desc = "Telescope Lsp Incoming Calls",
      },
      {
        "gO",
        "<cmd>Telescope lsp_outgoing_calls<CR>",
        desc = "Telescope Lsp_outgoing Calls",
      },
      {
        "gr",
        "<cmd>Telescope lsp_references show_line=false<CR>",
        desc = "Telescope Lsp References",
      },
      { "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>", desc = "Telescope Find Files" },
      { "<leader>fo", "<cmd>Telescope oldfiles only_cwd=true<cr>", desc = "Telescope Oldfiles" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Telescope Commands" },
      { "<leader>fa", "<cmd>Telescope autocommands<cr>", desc = "Telescope Autocommands" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Telescope Keymaps" },
      {
        "<leader>fg",
        '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>',
        desc = "Telescope Live Grep Args",
      },
      { "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "Telescope Quickfix" },
      { "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Telescope Registers" },
      { "<leader>fR", "<cmd>Telescope resume<cr>", desc = "Telescope Resume" },
      { "<leader>fi", "<cmd>Telescope loclist<cr>", desc = "Telescope Loclist" },
      { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Telescope Jumplist" },
      { "<leader>fu", "<cmd>Telescope undo<cr>", desc = "Telescope Undo" },
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Telescope Projects" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Telescope Buffers" },
      { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Telescope Marks" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Telescope Git Commits" },
      { "<leader>gh", "<cmd>Telescope git_stash<cr>", desc = "Telescope Git Stash" },
      { "<leader>gbc", "<cmd>Telescope git_bcommits<cr>", desc = "Telescope Git Bcommits" },
      { "<leader>gbb", "<cmd>Telescope git_branches<cr>", desc = "Telescope Git Branches" },
      { "<leader>fii", "<cmd>Telescope builtin<cr>", desc = "Telescope Builtin" },
      { "<leader>fic", "<cmd>Telescope colorscheme<cr>", desc = "Telescope Colorscheme" },
      { "<leader>fiv", "<cmd>Telescope vim_options<cr>", desc = "Telescope Vim Options" },
      {
        "<leader>fib",
        "<cmd>Telescope current_buffer_fuzzy_find<cr>",
        desc = "Telescope Current Buffer Fuzzy Find",
      },
      {
        "<leader>fit",
        "<cmd>Telescope current_buffer_tags<cr>",
        desc = "Telescope Current Buffer Tags",
      },
      { "<leader>fis", "<cmd>Telescope spell_suggest<cr>", desc = "Telescope Spell Suggest" },
      { "<leader>fir", "<cmd>Telescope reloader<cr>", desc = "Telescope Reloader" },
      { "<leader>fiT", "<cmd>Telescope tags<cr>", desc = "Telescope Tags" },
      { "<leader>fit", "<cmd>Telescope treesitter<cr>", desc = "Telescope Treesitter" },
      { "<leader>fif", "<cmd>Telescope filetypes<cr>", desc = "Telescope Filetypes" },
      { "<leader>fip", "<cmd>Telescope pickers<cr>", desc = "Telescope Pickers" },
      { "<leader>fim", "<cmd>Telescope man_pages<cr>", desc = "Telescope Man Pages" },
      { "<leader>fhh", "<cmd>Telescope help_tags<cr>", desc = "Telescope Help Tags" },
      { "<leader>fhl", "<cmd>Telescope highlights<cr>", desc = "Telescope Highlights" },
      { "<leader>fhc", "<cmd>Telescope command_history<cr>", desc = "Telescope Command History" },
      { "<leader>fhs", "<cmd>Telescope search_history<cr>", desc = "Telescope Search History" },
      { "<leader>fhq", "<cmd>Telescope quickfixhistory<cr>", desc = "Telescope Quickfix History" },
      { "<leader>fwD", "<cmd>Telescope diagnostics<cr>", desc = "Telescope Diagnostics" },
      {
        "<leader>fwd",
        '<cmd>lua require"telescope.builtin".diagnostics{bufnr=0}<cr>',
        desc = "Telescope Buf Diagnostics",
      },
      {
        "<leader>fws",
        "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
        desc = "Telescope Lsp Dynamic Workspace Symbols",
      },
      {
        "<leader>fwS",
        "<cmd>Telescope lsp_document_symbols<cr>",
        desc = "Telescope Lsp Document Symbols",
      },
      {
        "<leader>fwr",
        "<cmd>Telescope lsp_references show_line=false<cr>",
        desc = "Telescope Lsp References",
      },
    },
    dependencies = {
      { "debugloop/telescope-undo.nvim" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    config = function()
      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end
      local fileIgnorePatterns = os.getenv("TELESCOPE_FILE_IGNORE_PATTERNS")
      local fileIgnoreTable = nil
      if fileIgnorePatterns then
        fileIgnoreTable = {}
        for pattern in string.gmatch(fileIgnorePatterns, "%S+") do
          table.insert(fileIgnoreTable, pattern)
        end
      end
      local layout = require("telescope.actions.layout")
      local toggle_preview = function()
        layout.toggle_preview(vim.fn.bufnr())
      end
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = fileIgnoreTable or { "^.git/", "^node_modules/" },
          -- borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
          wrap_results = true,
          sorting_strategy = "ascending",
          layout_strategy = "vertical",
          layout_config = {
            horizontal = {
              prompt_position = "top",
            },
            vertical = {
              prompt_position = "top",
            },
          },
          dynamic_preview_title = true,
          mappings = {
            i = {
              -- example
              -- ["<C-o>"] = trouble.open_with_trouble,
              ["<M-v>"] = toggle_preview,
              ["<M-n>"] = require("telescope.actions").cycle_history_next,
              ["<M-p>"] = require("telescope.actions").cycle_history_prev,
              ["<C-s>"] = flash,
            },
            n = {
              ["<M-v>"] = toggle_preview,
              ["<M-n>"] = require("telescope.actions").cycle_history_next,
              ["<M-p>"] = require("telescope.actions").cycle_history_prev,
              ["<s>"] = flash,
            },
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--trim",
            "--hidden",
            "--multiline",
          },
        },
        pickers = {
          find_files = {
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case", the default case_mode is "smart_case"
          },
          ["ui-select"] = {
            require("telescope.themes").get_cursor({
              borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
              -- borderchars = {
              -- prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
              -- results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
              -- preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
              -- }
            }),
          },
          undo = {
            side_by_side = true,
            layout_strategy = "vertical",
            layout_config = {
              preview_height = 0.5,
            },
          },
        },
      })

      -- setup number and wrap for telescope previewer
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function(args)
          vim.wo.number = true
          vim.wo.wrap = true
        end,
      })

      require("telescope").load_extension("projects")
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("undo")
      require("telescope").load_extension("ui-select")
      require("telescope").load_extension("live_grep_args")
    end,
  },
  {
    "echasnovski/mini.files",
    cond = not_vscode,
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    lazy = true,
    keys = {
      { "<leader>fe", "<cmd>:lua MiniFiles.open()<cr>", desc = "MiniFiles Open" },
    },
    opts = {
      windows = {
        preview = true,
        width_preview = 40,
      },
    },
  },
}
