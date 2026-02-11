if vim.g.vscode then return end

local util = require('wenvim.util')
local map = util.map
local gh = util.gh
local augroup = util.augroup

-- Load mini.files immediately for sometimes we are gonna open folder with nvim
-- In this case mini.files can't be lazy load
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require('mini.files').setup({
  windows = {
    preview = true,
    width_preview = 40,
  },
})
map('n', '<leader>fe', MiniFiles.open, 'MiniFiles open')
-- send notification to lsp when mini.files rename actions triggered, modified from snacks.nvim
vim.api.nvim_create_autocmd('User', {
  group = augroup('mini_files_lsp_rename'),
  pattern = 'MiniFilesActionRename',
  callback = function(event) require('wenvim.util.lsp').on_rename_file(event.data.from, event.data.to) end,
})
-- Create mappings to modify target window via split
local map_split = function(buf_id, lhs, direction)
  local rhs = function()
    -- Make new window and set it as target
    local cur_target = MiniFiles.get_explorer_state().target_window
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. ' split')
      return vim.api.nvim_get_current_win()
    end)

    MiniFiles.set_target_window(new_target)

    -- This intentionally doesn't act on file under cursor in favor of
    -- explicit "go in" action (`l` / `L`). To immediately open file,
    -- add appropriate `MiniFiles.go_in()` call instead of this comment.
  end

  -- Adding `desc` will result into `show_help` entries
  local desc = 'Split ' .. direction
  vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
end

-- Create mappings which use data from entry under cursor
-- Set focused directory as current working directory
local set_cwd = function()
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then return vim.notify('Cursor is not on valid entry') end
  vim.fn.chdir(vim.fs.dirname(path))
end

-- Yank in register full path of entry under cursor
local yank_path = function()
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then return vim.notify('Cursor is not on valid entry') end
  vim.fn.setreg(vim.v.register, path)
end

-- Open path with system default handler (useful for non-text files)
local ui_open = function() vim.ui.open(MiniFiles.get_fs_entry().path) end

vim.api.nvim_create_autocmd('User', {
  group = augroup('mini_files_buf_mappings'),
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf_id = args.data.buf_id
    -- Tweak keys to your liking
    map_split(buf_id, '<C-s>', 'belowright horizontal')
    map_split(buf_id, '<C-v>', 'belowright vertical')
    vim.keymap.set('n', 'g~', set_cwd, { buffer = buf_id, desc = 'Set cwd' })
    vim.keymap.set('n', 'gx', ui_open, { buffer = buf_id, desc = 'OS open' })
    vim.keymap.set('n', 'gy', yank_path, { buffer = buf_id, desc = 'Yank path' })
  end,
})
-- Set custom bookmarks
local set_mark = function(id, path, desc) MiniFiles.set_bookmark(id, path, { desc = desc }) end
vim.api.nvim_create_autocmd('User', {
  group = augroup('mini_files_marks'),
  pattern = 'MiniFilesExplorerOpen',
  callback = function()
    local dotfiles_path = vim.env.DOTFILES
    local config_path = dotfiles_path and dotfiles_path .. '/xdg/config/nvim' or vim.fn.stdpath('config')
    set_mark('c', config_path, 'Config') -- path
    set_mark('w', vim.fn.getcwd, 'Working directory') -- callable
    set_mark('~', '~', 'Home directory')
    set_mark('.', function() return vim.fn.expand('#:p:h') end, 'Current directory')
  end,
})

-- visit recent files and we could add labels for files, easy to group files
require('mini.visits').setup()
map('n', '<leader>v', MiniVisits.add_label, 'MiniVisits add label')
map('n', '<leader>V', MiniVisits.remove_label, 'MiniVisits remove label')

-- mini.pick with lot custom keymaps
require('mini.pick').setup()
local show_with_icons = function(buf_id, items, query)
  return MiniPick.default_show(buf_id, items, query, { show_icons = true })
end
-- pick grep function that pass args to rg
MiniPick.registry.grep_args = function()
  local args = vim.fn.input('Ripgrep args: ')
  local command = {
    'rg',
    '--column',
    '--line-number',
    '--no-heading',
    '--field-match-separator=\\0',
    '--no-follow',
    '--color=never',
  }
  local args_table = vim.fn.split(args, ' ')
  vim.list_extend(command, args_table)

  return MiniPick.builtin.cli(
    { command = command },
    { source = { name = string.format('Grep (rg %s)', args), show = show_with_icons } }
  )
end
-- select terminals
MiniPick.registry.terminals = function()
  local dap_terms = util.filter_buffers('/^\\[dap-terminal\\]/')
  local terms = util.filter_buffers('/^term:\\/\\//')
  local items = vim.list_extend(terms, dap_terms)
  local terminal_opts = { source = { name = 'Terminal buffers', show = show_with_icons, items = items } }
  return MiniPick.start(terminal_opts)
end
-- pick cli output from user input
MiniPick.registry.input_cli = function()
  local input_cmd = vim.fn.input('Command: ')
  local cmd_tbl = vim.split(input_cmd, '%s+')
  return MiniPick.builtin.cli({ command = cmd_tbl })
end
map('n', '<leader>ft', '<cmd>Pick terminals<cr>', 'Pick terminals')
map('n', '<leader>fG', '<cmd>Pick grep_args<cr>', 'Pick grep with rg args')
map('n', '<leader>ff', '<cmd>Pick files<cr>', 'Pick files')
map('n', '<leader>fg', '<cmd>Pick grep_live<cr>', 'Pick grep live')
map('n', '<leader>fH', '<cmd>Pick help<cr>', 'Pick help')
map('n', '<leader>fb', '<cmd>Pick buffers<cr>', 'Pick buffers')
map('n', '<leader>fC', '<cmd>Pick colorschemes<cr>', 'Pick colorschemes')
map('n', '<leader>fi', '<cmd>Pick input_cli<cr>', 'Pick cli output from cmd')
map('n', '<leader>fR', '<cmd>Pick resume<cr>', 'Pick resume')
map('n', '<leader>fd', "<cmd>Pick diagnostic scope='current'<cr>", 'Pick current diagnostic')
map('n', '<leader>fD', "<cmd>Pick diagnostic scope='all'<cr>", 'Pick all diagnostic')
map('n', '<leader>gb', '<cmd>Pick git_branches<cr>', 'Pick git branches')
map('n', '<leader>gC', '<cmd>Pick git_commits<cr>', 'Pick git commits')
map('n', '<leader>gc', "<cmd>Pick git_commits path='%'<cr>", 'Pick git commits current')
map('n', '<leader>gf', '<cmd>Pick git_files<cr>', 'Pick git files')
map('n', '<leader>gH', '<cmd>Pick git_hunks<cr>', 'Pick git hunks')
map('n', '<leader>fP', '<cmd>Pick hipatterns<cr>', 'Pick hipatterns')
map('n', '<leader>fh', '<cmd>Pick history<cr>', 'Pick history')
map('n', '<leader>fL', '<cmd>Pick hl_groups<cr>', 'Pick hl groups')
map('n', '<leader>fk', '<cmd>Pick keymaps<cr>', 'Pick keymaps')
map('n', '<leader>fl', "<cmd>Pick list scope='location'<cr>", 'Pick location')
map('n', '<leader>fj', "<cmd>Pick list scope='jump'<cr>", 'Pick jump')
map('n', '<leader>fq', "<cmd>Pick list scope='quickfix'<cr>", 'Pick quickfix')
map('n', '<leader>fc', "<cmd>Pick list scope='change'<cr>", 'Pick change')
map('n', '<leader>fm', '<cmd>Pick marks<cr>', 'Pick marks')
map('n', '<leader>fO', '<cmd>Pick oldfiles<cr>', 'Pick oldfiles')
map('n', '<leader>fo', '<cmd>Pick oldfiles current_dir=true<cr>', 'Pick oldfiles current dir')
map('n', '<leader>fn', '<cmd>Pick options<cr>', 'Pick options')
map('n', '<leader>fr', '<cmd>Pick registers<cr>', 'Pick registers')
map('n', '<leader>fp', '<cmd>Pick spellsuggest<cr>', 'Pick spell suggest')
map('n', '<leader>fT', '<cmd>Pick treesitter<cr>', 'Pick treesitter')
map('n', '<leader>fv', '<cmd>Pick visit_paths<cr>', 'Pick visit paths')
map('n', '<leader>fV', '<cmd>Pick visit_labels<cr>', 'Pick visit labels')
map('n', '<leader>cd', "<cmd>Pick lsp scope='definition'<CR>", 'Pick lsp definition')
map('n', '<leader>cD', "<cmd>Pick lsp scope='declaration'<CR>", 'Pick lsp declaration')
map('n', '<leader>cr', "<cmd>Pick lsp scope='references'<cr>", 'Pick lsp references')
map('n', '<leader>ci', "<cmd>Pick lsp scope='implementation'<CR>", 'Pick lsp implementation')
map('n', '<leader>ct', "<cmd>Pick lsp scope='type_definition'<cr>", 'Pick lsp type definition')
map('n', '<leader>fs', "<cmd>Pick lsp scope='document_symbol'<cr>", 'Pick lsp document symbol')
map('n', '<leader>fS', "<cmd>Pick lsp scope='workspace_symbol_live'<cr>", 'Pick lsp workspace symbol')
