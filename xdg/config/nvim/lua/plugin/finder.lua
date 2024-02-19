return {
  {
    'nvim-telescope/telescope.nvim',
    cond = not vim.g.vscode,
    dependencies = {
      { 'debugloop/telescope-undo.nvim' },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-live-grep-args.nvim' },
      {
        'nvim-telescope/telescope-file-browser.nvim',
        branch = 'feat/tree'
      },
    },
    config = function()
      local function flash(prompt_bufnr)
        require('flash').jump({
          pattern = '^',
          label = { after = { 0, 0 } },
          search = {
            mode = 'search',
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'TelescopeResults'
              end,
            },
          },
          action = function(match)
            local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end
      local fileIgnorePatterns = os.getenv('TELESCOPE_FILE_IGNORE_PATTERNS')
      local fileIgnoreTable = nil
      if fileIgnorePatterns then
        fileIgnoreTable = {}
        for pattern in string.gmatch(fileIgnorePatterns, '%S+') do
          table.insert(fileIgnoreTable, pattern)
        end
      end
      local layout = require('telescope.actions.layout')
      local toggle_preview = function() layout.toggle_preview(vim.fn.bufnr()) end
      local fb_actions = require 'telescope._extensions.file_browser.actions'
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = fileIgnoreTable or nil,
          -- borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
          wrap_results = true,
          sorting_strategy = 'ascending',
          layout_strategy = 'vertical',
          layout_config = {
            horizontal = {
              prompt_position = 'top'
            },
            vertical = {
              prompt_position = 'top'
            },
          },
          dynamic_preview_title = true,
          mappings = {
            i = {
              -- example
              -- ["<C-o>"] = trouble.open_with_trouble,
              ['<M-v>'] = toggle_preview,
              ['<M-n>'] = require('telescope.actions').cycle_history_next,
              ['<M-p>'] = require('telescope.actions').cycle_history_prev,
              ['<C-s>'] = flash,
            },
            n = {
              ['<M-v>'] = toggle_preview,
              ['<M-n>'] = require('telescope.actions').cycle_history_next,
              ['<M-p>'] = require('telescope.actions').cycle_history_prev,
              ['<s>'] = flash,
            }
          },
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--trim',
            '--hidden',
            '--multiline'
          }
        },
        preview = {
          mime_hook = function(filepath, bufnr, opts)
            local is_image = function(filepath)
              local image_extensions = {'png','jpg'}   -- Supported image formats
              local split_path = vim.split(filepath:lower(), '.', {plain=true})
              local extension = split_path[#split_path]
              return vim.tbl_contains(image_extensions, extension)
            end
            if is_image(filepath) then
              local term = vim.api.nvim_open_term(bufnr, {})
              local function send_output(_, data, _ )
                for _, d in ipairs(data) do
                  vim.api.nvim_chan_send(term, d..'\r\n')
                end
              end
              vim.fn.jobstart(
                {
                  'catimg', filepath  -- Terminal image viewer command
                }, 
                {on_stdout=send_output, stdout_buffered=true, pty=true})
            else
              require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
            end
          end
        },
        pickers = {
          find_files = {
            find_command = { 'fd', '--type', 'f', '--strip-cwd-prefix' }
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,                 -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,  -- override the file sorter
            case_mode = 'smart_case',     -- or "ignore_case" or "respect_case", the default case_mode is "smart_case"
          },
          ['ui-select'] = {
            require('telescope.themes').get_cursor {
              borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
              -- borderchars = {
              -- prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
              -- results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
              -- preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
              -- }
            }
          },
          undo = {
            side_by_side = true,
            layout_strategy = 'vertical',
            layout_config = {
              preview_height = 0.5,
            },
          },
          file_browser = {
            hide_parent_dir = true,
            respect_gitignore = false,
            select_buffer = true,
            grouped = true,
            auto_depth = true,
            initial_browser = 'tree',
            follow = true,
            path = '%:p:h',
            prompt_path = true,
            hijack_netrw = true,
            mappings = {
              ['i'] = {
                ['<A-o>'] = fb_actions.open,
                ['<C-b>'] = fb_actions.backspace,
                ['<C-o>'] = 'select_default',
              },
              ['n'] = {
                -- your custom normal mode mappings
                ['b'] = fb_actions.backspace,
                ['o'] = 'select_default',
                ['<A-o>'] = fb_actions.open,
              },
            },
          },
        }
      })

      -- setup number and wrap for telescope previewer
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function(args)
          vim.wo.number = true
          vim.wo.wrap = true
        end,
      })

      require('telescope').load_extension('projects')
      require('telescope').load_extension('fzf')
      require('telescope').load_extension('undo')
      require('telescope').load_extension('ui-select')
      require('telescope').load_extension('live_grep_args')
      require('telescope').load_extension('file_browser')
    end
  },
  { 'echasnovski/mini.files',
    cond = not vim.g.vscode,
    opts = {
      windows = {
        preview = true,
        width_preview = 40,
      }
    }
  }
}
