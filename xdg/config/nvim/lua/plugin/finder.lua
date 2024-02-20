return {
  {
    'nvim-telescope/telescope.nvim',
    cond = not vim.g.vscode,
    cmd = 'Telescope',
    keys = {
      { 'gd',          '<cmd>Telescope lsp_definitions<CR>' },
      { 'gi',          '<cmd>Telescope lsp_implementations<CR>' },
      { 'gI',          '<cmd>Telescope lsp_incoming_calls<CR>' },
      { 'gO',          '<cmd>Telescope lsp_outgoing_calls<CR>' },
      { 'gr',          '<cmd>Telescope lsp_references show_line=false<CR>' },
      { '<leader>ff',  '<cmd>Telescope find_files hidden=true<cr>' },
      { '<leader>fo',  '<cmd>Telescope oldfiles only_cwd=true<cr>' },
      { '<leader>ff',  '<cmd>Telescope find_files hidden=true<cr>' },
      { '<leader>fc',  '<cmd>Telescope commands<cr>' },
      { '<leader>fa',  '<cmd>Telescope autocommands<cr>' },
      { '<leader>fk',  '<cmd>Telescope keymaps<cr>' },
      { '<leader>fg',  '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>' },
      { '<leader>fq',  '<cmd>Telescope quickfix<cr>' },
      { '<leader>fr',  '<cmd>Telescope registers<cr>' },
      { '<leader>fR',  '<cmd>Telescope resume<cr>' },
      { '<leader>fi',  '<cmd>Telescope loclist<cr>' },
      { '<leader>fj',  '<cmd>Telescope jumplist<cr>' },
      { '<leader>fu',  '<cmd>Telescope undo<cr>' },
      { '<leader>fp',  '<cmd>Telescope projects<cr>' },
      { '<leader>fb',  '<cmd>Telescope buffers<cr>' },
      { '<leader>fm',  '<cmd>Telescope marks<cr>' },
      { '<leader>gc',  '<cmd>Telescope git_commits<cr>', },
      { '<leader>gh',  '<cmd>Telescope git_stash<cr>', },
      { '<leader>gbc', '<cmd>Telescope git_bcommits<cr>', },
      { '<leader>gbb', '<cmd>Telescope git_branches<cr>', },
      { '<leader>fii', '<cmd>Telescope builtin<cr>' },
      { '<leader>fic', '<cmd>Telescope colorscheme<cr>' },
      { '<leader>fiv', '<cmd>Telescope vim_options<cr>' },
      { '<leader>fib', '<cmd>Telescope current_buffer_fuzzy_find<cr>' },
      { '<leader>fit', '<cmd>Telescope current_buffer_tags<cr>' },
      { '<leader>fis', '<cmd>Telescope spell_suggest<cr>' },
      { '<leader>fir', '<cmd>Telescope reloader<cr>' },
      { '<leader>fiT', '<cmd>Telescope tags<cr>' },
      { '<leader>fit', '<cmd>Telescope treesitter<cr>' },
      { '<leader>fif', '<cmd>Telescope filetypes<cr>' },
      { '<leader>fip', '<cmd>Telescope pickers<cr>' },
      { '<leader>fim', '<cmd>Telescope man_pages<cr>' },
      { '<leader>fhh', '<cmd>Telescope help_tags<cr>' },
      { '<leader>fhl', '<cmd>Telescope highlights<cr>' },
      { '<leader>fhc', '<cmd>Telescope command_history<cr>' },
      { '<leader>fhs', '<cmd>Telescope search_history<cr>' },
      { '<leader>fhq', '<cmd>Telescope quickfixhistory<cr>' },
      { '<leader>fwD', '<cmd>Telescope diagnostics<cr>' },
      { '<leader>fwd', '<cmd>lua require"telescope.builtin".diagnostics{bufnr=0}<cr>' },
      { '<leader>fws', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>' },
      { '<leader>fwS', '<cmd>Telescope lsp_document_symbols<cr>' },
      { '<leader>fwr', '<cmd>Telescope lsp_references show_line=false<cr>' },
    },
    dependencies = {
      { 'debugloop/telescope-undo.nvim' },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-live-grep-args.nvim' },
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
    end
  },
  { 'echasnovski/mini.files',
    cond = not vim.g.vscode,
    lazy = true,
    keys = {
      { '<leader>fe', '<cmd>:lua MiniFiles.open()<cr>' }
    },
    opts = {
      windows = {
        preview = true,
        width_preview = 40,
      }
    }
  }
}
