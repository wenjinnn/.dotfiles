local util = require('wenvim.util')
local map = util.map
local augroup = util.augroup
local gh = util.gh
local cb = util.cb

-- textobject enhancement
local gen_ai_spec = require('mini.extra').gen_ai_spec
local gen_spec = require('mini.ai').gen_spec
require('mini.ai').setup({
  mappings = {
    -- Next/last textobjects, setup with uppercase letters so that they don't conflict with default an in mappings
    around_next = 'aN',
    inside_next = 'iN',
    around_last = 'aL',
    inside_last = 'iL',
  },
  custom_textobjects = {
    B = gen_ai_spec.buffer(),
    D = gen_ai_spec.diagnostic(),
    I = gen_ai_spec.indent(),
    L = gen_ai_spec.line(),
    N = gen_ai_spec.number(),
    -- Function definition (needs treesitter queries with these captures)
    -- This need nvim-treesitter-textobjects, see https://github.com/echasnovski/mini.nvim/issues/947#issuecomment-2154242659
    F = gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
    -- Make `|` select both edges in non-balanced way
    O = gen_spec.treesitter({
      a = { '@conditional.outer', '@loop.outer' },
      i = { '@conditional.inner', '@loop.inner' },
    }),
    C = gen_spec.treesitter({
      a = { '@comment.outer', '@class.outer' },
      i = { '@comment.inner', '@class.inner' },
    }),
    ['|'] = gen_spec.pair('|', '|', { type = 'non-balanced' }),
  },
  n_lines = 500,
})

-- customize mini.splitjoin
local gen_hook = require('mini.splitjoin').gen_hook
local curly = { brackets = { '%b{}' } }
-- Add trailing comma when splitting inside curly brackets
local add_comma_curly = gen_hook.add_trailing_separator(curly)
-- Delete trailing comma when joining inside curly brackets
local del_comma_curly = gen_hook.del_trailing_separator(curly)
-- Pad curly brackets with single space after join
local pad_curly = gen_hook.pad_brackets(curly)
require('mini.splitjoin').setup({
  split = { hooks_post = { add_comma_curly } },
  join = { hooks_post = { del_comma_curly, pad_curly } },
})

-- setup mini.surround and disable original `s` functionality to reduce key wait time
require('mini.surround').setup({
  custom_surroundings = {
    -- workaround for html tag with attributes surrounding, see https://github.com/echasnovski/mini.nvim/issues/1293#issuecomment-2423827325
    T = {
      input = { '<([%w_-%.]-)%f[^<%w_-%.][^<>]->.-</%1>', '^<()[%w_-%.]+().*</()[%w_-%.]+()>$' },
      output = function()
  local tag_name = MiniSurround.user_input('Tag name')
  if tag_name == nil then return nil end
  return { left = tag_name, right = tag_name }
      end,
    },
    t = {
      input = { '<([%w_-%.]-)%f[^<%w_-%.][^<>]->.-</%1>', '^<.->().*()</[^/]->$' },
    },
  },
  n_lines = 100,
})
vim.keymap.set({ 'n', 'x' }, 's', '<Nop>')

-- treesitter related
vim.pack.add({
  gh('nvim-treesitter/nvim-treesitter'),
  gh('hiphish/rainbow-delimiters.nvim'),
  gh('nvim-treesitter/nvim-treesitter-context'),
  gh('nvim-treesitter/nvim-treesitter-textobjects'),
})
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    -- Run build script after plugin's code has changed
    if name == 'nvim-treesitter' and kind == 'update' then vim.cmd('TSUpdate') end
  end,
})
local ts_config = require('nvim-treesitter.config')
-- always check current buffer's filetype and async install related parsers
local enable_ts = function(buf, lang)
  vim.wo.foldmethod = 'expr'
  vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  if not vim.g.vscode then vim.treesitter.start(buf, lang) end
end
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  group = augroup('ts_parser_auto_installation'),
  callback = function(event)
    local filetype = event.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if not vim.tbl_contains(ts_config.get_available(), lang) then return end
    if not vim.tbl_contains(ts_config.get_installed('parsers'), lang) then
      require('nvim-treesitter').install(lang):await(function() enable_ts(event.buf, lang) end)
    else
      enable_ts(event.buf, lang)
    end
  end,
})
local function go_to_context() require('treesitter-context').go_to_context(vim.v.count1) end
map('n', '[C', go_to_context, 'treesitter context upward')

-- conform with some auto format setting
vim.pack.add({ gh('stevearc/conform.nvim') })
require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    nix = { 'nixfmt' },
    sql = { 'sqlfluff' },
    python = { 'ruff_format' },
  },
  formatters = {
    -- override default sqlfluff config to let it work without extra config file
    sqlfluff = {
      args = { 'fix', '--dialect', 'ansi', '-q', '-' },
      cwd = nil,
      require_cwd = false,
      exit_codes = { 0, 1 },
    },
  },
})
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.g.conform_autoformat = true
-- NOTE diff_format is not work well with some formatter, in this case, use code_format manually
local diff_format = function()
  local data = MiniDiff.get_buf_data()
  if not data or not data.hunks or not vim.g.conform_autoformat then
    vim.notify('No hunks in this buffer or auto format is currently disabled')
    return
  end
  local ranges = {}
  for _, hunk in pairs(data.hunks) do
    if hunk.type ~= 'delete' then
      local last = hunk.buf_start + hunk.buf_count - 1
      local last_hunk_line = vim.api.nvim_buf_get_lines(0, last - 1, last, true)[1]
      local range = { start = { hunk.buf_start, 0 }, ['end'] = { last, last_hunk_line:len() } }
      -- always insert to index 1 so format below could start from last hunk, which this sort didn't mess up range
      table.insert(ranges, 1, range)
    end
  end
  for _, range in pairs(ranges) do
    require('conform').format({ lsp_fallback = true, timeout_ms = 500, range = range })
  end
end
vim.api.nvim_create_user_command('DiffFormat', diff_format, { desc = 'Format changed lines' })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup('conform_diffformat'),
  pattern = '*',
  callback = diff_format,
  desc = 'Auto format changed lines',
})
local function code_format() require('conform').format({ async = true, lsp_fallback = true }) end
local function auto_format_toggle()
  vim.g.conform_autoformat = not vim.g.conform_autoformat
  vim.notify('Autoformat: ' .. (vim.g.conform_autoformat and 'on' or 'off'))
end
map({ 'n', 'v' }, '<leader>cf', code_format, 'Format')
map('n', '<leader>cF', auto_format_toggle, 'Auto format toggle')

-- load some editing support mini modules at once
require('mini.align').setup()
require('mini.comment').setup()
require('mini.bracketed').setup({
  -- adjust comment mapping for conflict with vim-fugitive
  comment = { suffix = 'e' },
})
require('mini.pairs').setup()
require('mini.operators').setup({ exchange = { prefix = 'gX' } })
require('mini.trailspace').setup()
-- automatic trim trailspace on write a buffer, this should be defined after conform.nvim setup
-- for if trim trailspace done before conform diff_format autocmd, it will mess up lines index
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = augroup('mini_trim_trailspace'),
  callback = function()
    MiniTrailspace.trim()
    MiniTrailspace.trim_last_lines()
  end,
})

local map_multistep = require('mini.keymap').map_multistep

map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
map_multistep('i', '<Tab>', { 'pmenu_next', 'increase_indent' })
map_multistep('i', '<S-Tab>', { 'pmenu_prev', 'decrease_indent' })

-- we don't need below plugins in vscode
if vim.g.vscode then return end

-- customize mini.sessions setup
local function pre_read()
  -- When MiniMiscAutoRoot au is setup, and session window buffers has different root
  -- restoring a session may cause a empty buffer.
  vim.api.nvim_del_augroup_by_name('MiniMiscAutoRoot')
end
local function post_read()
  MiniMisc.setup_auto_root()
  require('wenvim.util').delete_dap_terminals()
end

require('mini.sessions').setup({
  -- Whether to force possibly harmful actions (meaning depends on function)
  force = { read = false, write = true, delete = true },
  hooks = {
    -- Before successful action
    pre = { read = pre_read, write = nil, delete = nil },
    -- After successful action
    post = { read = post_read, write = nil, delete = nil },
  },
})
local session_name = function()
  local cwd = vim.fn.getcwd()
  local parent_path = vim.fn.fnamemodify(cwd, ':h')
  local current_tail_path = vim.fn.fnamemodify(cwd, ':t')
  local git_data = MiniGit.get_buf_data(0)
  local git_branch = git_data and git_data.head_name .. '@' or ''
  return string.format('%s@%s%s', current_tail_path, git_branch, parent_path:gsub('/', '_'))
end
local function session_write() require('mini.sessions').write(session_name()) end
local function session_write_custom() MiniSessions.write(vim.fn.input('Session name: ')) end
local function session_delete() require('mini.sessions').delete(session_name()) end
local function session_delete_custom() MiniSessions.delete(vim.fn.input('Session name: ')) end
map('n', '<leader>sw', session_write, 'Session write')
map('n', '<leader>sW', session_write_custom, 'Session write custom')
map('n', '<leader>sd', session_delete, 'Session delete')
map('n', '<leader>sD', session_delete_custom, 'Session delete custom')
map('n', '<leader>ss', MiniSessions.select, 'Session select')

require('mini.bufremove').setup()
map('n', '<leader>x', '<cmd>lua MiniBufremove.delete()<CR>', 'Buf delete')

-- basic lint setup
vim.pack.add({ cb('mfussenegger/nvim-lint') })
local lint = require('lint')
lint.linters_by_ft = {
  markdown = { 'vale' },
  sql = { 'sqlfluff' },
  python = { 'ruff' },
  javascript = { 'eslint' },
  typescript = { 'eslint' },
  vue = { 'eslint' },
}
-- just use the default lint
-- TODO maybe add more linter in future
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave', 'TextChanged' }, {
  group = augroup('lint'),
  callback = function(ev)
    if not require('wenvim.util').is_floating_win(ev.buf) then
      lint.try_lint()
      lint.try_lint('compiler')
    end
  end,
})

-- completion and snippets
require('mini.cmdline').setup()
require('mini.completion').setup()

-- snippet support and preset
vim.pack.add({ gh('rafamadriz/friendly-snippets') })
local gen_loader = require('mini.snippets').gen_loader
local snippets_path = vim.fn.stdpath('config') .. '/snippets'
require('mini.snippets').setup({
  snippets = {
    -- Load custom file with global snippets first
    -- For variables in snippets json, see https://code.visualstudio.com/docs/editor/userdefinedsnippets
    gen_loader.from_file(snippets_path .. '/global.json'),
    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
    -- Load project-local snippets with `gen_loader.from_file()`
    -- and relative path (file doesn't have to be present)
    gen_loader.from_file('.vscode/project.code-snippets'),
    -- Custom loader for language-specific project-local snippets
    function(context)
      local rel_path = '.vscode/' .. context.lang .. '.code-snippets'
      if vim.fn.filereadable(rel_path) == 0 then return end
      return MiniSnippets.read_file(rel_path)
    end,
  },
})

-- painless snippet editing and creation
vim.pack.add({ gh('chrisgrieser/nvim-scissors') })
require('scissors').setup({
  snippetDir = snippets_path,
  jsonFormatter = 'jq',
  backdrop = { enabled = false },
})
map('n', '<leader>cS', '<cmd>ScissorsEditSnippet<cr>', 'Snippet edit')
map({ 'n', 'x' }, '<leader>cs', '<cmd>ScissorsAddNewSnippet<cr>', 'Snippet add')

-- annotation and comment generation
vim.pack.add({ gh('danymat/neogen') })
require('neogen').setup({ snippet_engine = 'mini' })
map('n', '<leader>cA', '<cmd>Neogen<cr>', 'Generate annotation')

vim.pack.add({ gh('monaqa/dial.nvim') })
map({ 'n', 'x' }, '<C-a>', function() require('dial.map').manipulate('increment', 'normal') end, 'Dial increment')
map({ 'n', 'x' }, 'g<C-a>', function() require('dial.map').manipulate('increment', 'gnormal') end, 'Dial increment')
map({ 'n', 'x' }, '<C-x>', function() require('dial.map').manipulate('decrement', 'normal') end, 'Dial decrement')
map({ 'n', 'x' }, 'g<C-x>', function() require('dial.map').manipulate('decrement', 'gnormal') end, 'Dial decrement')
