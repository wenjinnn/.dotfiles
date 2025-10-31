local M = {}
M.opts = { noremap = true, silent = true }

function M.make_opts(opts)
  if type(opts) == 'string' then
    -- in most case we just want add some description
    opts = { desc = opts }
  end
  return vim.tbl_extend('keep', opts, M.opts)
end

-- Delete all dap terminals, useful when session restored, cuz in that timing sometimes we have some dead dap terminals.
function M.delete_dap_terminals()
  local dap_terminals_output = vim.api.nvim_exec2('filter /\\[dap-terminal\\]/ buffers', { output = true })
  local dap_terminals = vim.split(dap_terminals_output.output, '\n')
  local buffers_index = {}
  for _, terminal in ipairs(dap_terminals) do
    local buf_args = vim.split(vim.trim(terminal), ' ')
    local buf_index = tonumber(buf_args[1])
    if buf_index ~= nil then table.insert(buffers_index, buf_index) end
  end
  if #buffers_index > 0 then vim.cmd('bd! ' .. vim.fn.join(buffers_index, ' ')) end
end

function M.augroup(name, opts)
  local final_opts = opts or { clear = true }
  return vim.api.nvim_create_augroup('wenvim_' .. name, final_opts)
end

function M.map(mode, lhs, rhs, opts) vim.keymap.set(mode, lhs, rhs, M.make_opts(opts)) end

function M.buf_map(bufnr)
  return function(mode, lhs, rhs, desc)
    local opts = M.make_opts({ desc = desc, buffer = bufnr })
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

function M.source_all()
  local config_bundles = vim.split(vim.fn.glob(vim.fn.stdpath('config') .. '/**/*.lua'), '\n')
  local vim_config_bundles = vim.split(vim.fn.glob(vim.fn.stdpath('config') .. '/**/*.vim'), '\n')
  vim.list_extend(config_bundles, vim_config_bundles)
  for _, config in pairs(config_bundles) do
    vim.cmd.source(config)
  end
end

function M.toggle_win_diff()
  if vim.wo.diff then
    vim.cmd('windo diffoff')
  else
    vim.cmd('windo diffthis')
    vim.cmd('windo set wrap')
  end
end

function M.toggle_qf()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      vim.cmd('cclose')
      return
    end
  end
  vim.cmd('copen')
end

function M.toggle_loc()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.loclist == 1 then
      vim.cmd('lclose')
      return
    end
  end
  vim.cmd('lopen')
end

function M.filter_buffers(pattern, cmd_opts)
  cmd_opts = cmd_opts or {}
  local items = {}
  local buffers_output =
    vim.api.nvim_exec2('filter' .. (cmd_opts.revert and '! ' or ' ') .. pattern .. ' ls', { output = true })
  if buffers_output.output ~= '' then
    for _, l in ipairs(vim.split(buffers_output.output, '\n')) do
      local buf_str, name = l:match('^%s*%d+'), l:match('"(.*)"')
      local buf_id = tonumber(buf_str)
      local item = { text = name, bufnr = buf_id }
      table.insert(items, item)
    end
  end
  return items
end

function M.is_floating_win(bufnr)
  local win_buf = vim.api.nvim_win_get_buf(0)
  local win = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(win)
  return bufnr == win_buf and config.relative ~= ''
end

return M
