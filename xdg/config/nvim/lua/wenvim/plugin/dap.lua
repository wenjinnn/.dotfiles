if vim.g.vscode then return end

-- nvim debug
local add, later = MiniDeps.add, MiniDeps.later
later(function()
  add({
    source = 'mfussenegger/nvim-dap',
    depends = {
      'mfussenegger/nvim-dap-python',
      'jbyuki/one-small-step-for-vimkind',
    },
  })
  local dap = require('dap')
  local util = require('wenvim.util')
  local map = util.map

  dap.defaults.fallback.terminal_win_cmd = 'tabnew'

  dap.adapters.gdb = {
    type = 'executable',
    command = 'gdb',
    args = { '-i', 'dap' },
  }

  dap.configurations.lua = {
    {
      type = 'nlua',
      request = 'attach',
      name = 'Attach to running Neovim instance',
    },
  }

  dap.adapters.nlua = function(callback, config)
    callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
  end

  dap.configurations.rust = {
    {
      name = 'Launch',
      type = 'gdb',
      request = 'launch',
      program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
      cwd = '${workspaceFolder}',
      stopAtBeginningOfMainSubprogram = false,
    },
  }

  -- enable dap builtin auto completion
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = 'dap-repl',
    group = util.augroup('dap_repl'),
    callback = function() require('dap.ext.autocompl').attach() end,
  })

  -- setup dap python and virtual text
  local dap_python = require('dap-python')
  dap_python.setup('python')
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = 'python',
    group = util.augroup('dap_python'),
    callback = function(ev)
      local buf_map = util.buf_map(ev.buf)
      buf_map('n', '<leader>dm', dap_python.test_method, 'Dap test method')
      buf_map('n', '<leader>da', dap_python.test_class, 'Dap test class')
      buf_map('v', '<leader>dv', dap_python.debug_selection, 'Dap debug selection')
    end,
  })

  -- dap function wrapper for keymap
  local function breakpoints_quickfix()
    dap.list_breakpoints()
    vim.cmd('copen')
  end
  local function dap_continue()
    -- fix java dap setup failed sometime
    if vim.bo.filetype == 'java' and require('dap').configurations.java == nil then require('lsp.jdtls').setup_dap() end
    dap.continue()
  end

  local function dap_set_breakpoint() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end
  local function dap_set_logpoint() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end
  local function dap_set_exc_breakpoint() dap.set_exception_breakpoints('default') end
  local function dap_repl_toggle()
    dap.repl.toggle()
    vim.cmd('wincmd p')
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = 0 })
    if filetype == 'dap-repl' then vim.cmd('startinsert') end
  end
  local widgets = require('dap.ui.widgets')
  local function dap_hover() widgets.hover('<cexpr>', { title = 'dap-hover' }) end

  -- simple custom dap ui, cursor float window takes up the least screen space.
  local function dap_ui(widget, title)
    return function() widgets.cursor_float(widget, { title = title }) end
  end

  local function osv_launch() require('osv').launch({ port = 8086 }) end

  map('n', '<leader>db', dap.toggle_breakpoint, 'Dap toggle breakpoint')
  map('n', '<leader>dd', dap.clear_breakpoints, 'Dap clear breakpoint')
  map('n', '<leader>dr', dap.run_last, 'Dap run last')
  map('n', '<leader>dC', dap.run_to_cursor, 'Dap run to cursor')
  map('n', '<leader>do', dap.step_over, 'Dap step over')
  map('n', '<leader>dp', dap.step_back, 'Dap step back')
  map('n', '<leader>di', dap.step_into, 'Dap step into')
  map('n', '<leader>dO', dap.step_out, 'Dap step out')
  map('n', '<leader>de', dap.reverse_continue, 'Dap reverse continue')
  map('n', '<leader>dF', dap.restart_frame, 'Dap restart frame')
  map('n', '<leader>ds', dap_ui(widgets.scopes, 'dap-scopes'), 'Dap scopes')
  map('n', '<leader>df', dap_ui(widgets.frames, 'dap-frames'), 'Dap frames')
  map('n', '<leader>de', dap_ui(widgets.expression, 'dap-expression'), 'Dap expression')
  map('n', '<leader>dt', dap_ui(widgets.threads, 'dap-threads'), 'Dap threads')
  map('n', '<leader>dS', dap_ui(widgets.sessions, 'dap-sessions'), 'Dap sessions')
  map('n', '<leader>dq', breakpoints_quickfix, 'Dap list breakpoints')
  map('n', '<leader>dc', dap_continue, 'Dap continue')
  map('n', '<leader>dB', dap_set_breakpoint, 'Dap condition breakpoint')
  map('n', '<leader>dl', dap_set_logpoint, 'Dap log breakpoint')
  map('n', '<leader>dN', osv_launch, 'Dap osv launch')
  map('n', '<leader>dE', '<cmd>DapEval<CR>', 'Dap eval buffer')
  map('n', '<leader>dx', dap_set_exc_breakpoint, 'Dap exception breakpoint')
  map('n', '<leader>dR', dap_repl_toggle, 'Dap repl toggle')
  map('n', '<leader>dh', dap_hover, 'Dap hover')
  map('n', '<leader>dn', '<cmd>DapNew<CR>', 'Dap new')
end)
