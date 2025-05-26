local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local map = require('util').map

-- textobject enhancement
later(function()
  local gen_ai_spec = require('mini.extra').gen_ai_spec
  local gen_spec = require('mini.ai').gen_spec
  require('mini.ai').setup({
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
      o = gen_spec.treesitter({
        a = { '@conditional.outer', '@loop.outer' },
        i = { '@conditional.inner', '@loop.inner' },
      }),
      c = gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
      C = gen_spec.treesitter({ a = '@comment.outer', i = '@comment.inner' }),
      ['|'] = gen_spec.pair('|', '|', { type = 'non-balanced' }),
    },
    n_lines = 500,
  })
end)

-- customize mini.splitjoin
later(function()
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
end)

-- setup mini.surround and disable original `s` functionality to reduce key wait time
later(function()
  require('mini.surround').setup()
  vim.keymap.set({ 'n', 'x' }, 's', '<Nop>')
end)

-- treesitter related
later(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    -- TODO remove this line when it is stable
    checkout = 'main',
    depends = {
      'windwp/nvim-ts-autotag',
      'hiphish/rainbow-delimiters.nvim',
      'nvim-treesitter/nvim-treesitter-context',
      -- TODO also remove this line when it is stable
      { source = 'nvim-treesitter/nvim-treesitter-textobjects', checkout = 'main' },
    },
    hooks = {
      post_checkout = function() vim.cmd('TSUpdate') end,
    },
  })
  local treesitter_languages = {
    -- basic
    'vim',
    'vimdoc',
    'regex',
    'markdown',
    'lua',
    'luadoc',
    'luap',
    'query',
    'bash',
    'diff',
    'markdown_inline',
    'make',
    -- autotag dependencies
    'astro',
    'glimmer',
    'html',
    'javascript',
    'markdown',
    'php',
    'svelte',
    'tsx',
    'typescript',
    'vue',
    'xml',
    -- personal frequently used
    'nix',
    'java',
    'javadoc',
    'rust',
    'python',
    'sql',
    'css',
    'scss',
    'yaml',
    'c',
    'c_sharp',
    'cmake',
    'comment',
    'cpp',
    'csv',
    'desktop',
    'diff',
    'editorconfig',
    'dockerfile',
    'ssh_config',
    'http',
    'git_config',
    'git_rebase',
    'git_rebase',
    'gitattributes',
    'gitcommit',
    'gitignore',
    'ini',
    'jq',
    'jsdoc',
    'json',
    'json5',
    'jsonc',
    'latex',
    'mermaid',
    'toml',
  }
  require('nvim-treesitter').install(treesitter_languages)
  local disable_filetypes = {
    'mininotify',
    'minipick',
    'minifiles',
  }
  vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function()
      if vim.tbl_contains(disable_filetypes, vim.bo.filetype) then return end

      -- syntax highlighting, provided by Neovim
      if not vim.g.vscode then vim.treesitter.start() end
      -- folds, provided by Neovim
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      -- indentation, provided by nvim-treesitter
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
  require('nvim-ts-autotag').setup()
  local function go_to_context() require('treesitter-context').go_to_context(vim.v.count1) end
  map('n', '[e', go_to_context, 'treesitter context upward')
end)

later(function()
  -- load some editing support mini modules at once
  require('mini.align').setup()
  require('mini.bracketed').setup()
  require('mini.pairs').setup()
  require('mini.operators').setup({ exchange = { prefix = 'gX' } })
  require('mini.trailspace').setup()
  -- automatic trim trailspace on write a buffer
  vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    callback = function()
      MiniTrailspace.trim()
      MiniTrailspace.trim_last_lines()
    end,
  })

  local map_multistep = require('mini.keymap').map_multistep

  map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
  local forward_steps = {
    'minisnippets_next',
    'jump_after_tsnode',
    'jump_after_close',
  }
  map_multistep('i', '<C-l>', forward_steps)
  local backward_steps = {
    'minisnippets_prev',
    'jump_before_tsnode',
    'jump_before_open',
  }
  map_multistep('i', '<C-h>', backward_steps)

  map_multistep('i', '<Tab>', { 'pmenu_next', 'increase_indent' })
  map_multistep('i', '<S-Tab>', { 'pmenu_prev', 'decrease_indent' })
end)

-- we don't need below plugins in vscode
if vim.g.vscode then return end

-- customize mini.sessions setup
now(function()
  local function pre_read()
    -- When MiniMiscAutoRoot au is setup, and session window buffers has different root
    -- restoring a session may cause a empty buffer.
    vim.api.nvim_del_augroup_by_name('MiniMiscAutoRoot')
  end
  local function post_read()
    MiniMisc.setup_auto_root()
    require('util').delete_dap_terminals()
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
    return string.format('%s@%s', current_tail_path, parent_path:gsub('/', '-'))
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
end)

later(function()
  require('mini.bufremove').setup()
  map('n', '<leader>x', '<cmd>lua MiniBufremove.delete()<CR>', 'Buf delete')
end)

-- basic lint setup
later(function()
  add('mfussenegger/nvim-lint')
  local lint = require('lint')
  -- just use the default lint
  -- TODO maybe add more linter in future
  lint.linters_by_ft = {}
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    callback = function()
      lint.try_lint()
      lint.try_lint('compiler')
    end,
  })
end)

-- conform with some auto format setting
later(function()
  add('stevearc/conform.nvim')
  require('conform').setup({
    formatters_by_ft = {
      lua = { 'stylua' },
      nix = { 'nixfmt' },
      http = { 'kulala-fmt' },
    },
  })
  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  vim.g.conform_autoformat = true
  local diff_format = function()
    local data = MiniDiff.get_buf_data()
    if not data or not data.hunks or not vim.g.conform_autoformat then
      vim.notify('No hunks in this buffer or auto format is currently disabled')
      return
    end
    local ranges = {}
    for _, hunk in pairs(data.hunks) do
      if hunk.type ~= 'delete' then
        -- always insert to index 1 so format below could start from last hunk, which this sort didn't mess up range
        table.insert(ranges, 1, {
          start = { hunk.buf_start, 0 },
          ['end'] = { hunk.buf_start + hunk.buf_count, 0 },
        })
      end
    end
    for _, range in pairs(ranges) do
      require('conform').format({ lsp_fallback = true, timeout_ms = 500, range = range })
    end
  end
  vim.api.nvim_create_user_command('DiffFormat', diff_format, { desc = 'Format changed lines' })
  vim.api.nvim_create_autocmd('BufWritePre', {
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
end)

-- completion and snippets
later(function()
  require('mini.completion').setup()

  -- snippet support and preset
  add('rafamadriz/friendly-snippets')
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
  add('chrisgrieser/nvim-scissors')
  require('scissors').setup({
    snippetDir = snippets_path,
    jsonFormatter = 'jq',
    backdrop = { enabled = false },
  })
  map('n', '<leader>cS', '<cmd>ScissorsEditSnippet<cr>', 'Snippet edit')
  map({ 'n', 'x' }, '<leader>cs', '<cmd>ScissorsAddNewSnippet<cr>', 'Snippet add')

  -- annotation and comment generation
  add('danymat/neogen')
  require('neogen').setup({ snippet_engine = 'mini' })
  map('n', '<leader>cA', '<cmd>Neogen<cr>', 'Generate annotation')
end)
