local M = {}
M.opts = { noremap = true, silent = true }

function M.make_opts(opts) return vim.tbl_extend('keep', opts, M.opts) end

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

function M.map(mode, lhs, rhs, opts)
  -- default options
  local final_opts = { noremap = true, silent = true }
  if type(opts) == 'string' then
    -- in most case we just want add some description
    final_opts.desc = opts
  elseif type(opts) == 'table' then
    -- other case, just take the opts
    final_opts = opts
  end
  vim.keymap.set(mode, lhs, rhs, final_opts)
end

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

return M
