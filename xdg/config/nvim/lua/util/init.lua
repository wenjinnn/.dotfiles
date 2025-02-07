local M = {}

-- We don't want signcolumn, number, spell and indentscope for terminal
function M.setup_term_opt(event)
  vim.opt_local.number = false
  vim.opt_local.signcolumn = "no"
  vim.opt_local.relativenumber = false
  vim.opt_local.spell = false
  vim.b.miniindentscope_disable = true
end

-- Delete all dap terminals, useful when session restored, cuz in that timing sometimes we have some dead dap terminals.
function M.delete_dap_terminals()
  local dap_terminals_output = vim.api.nvim_exec2("filter /\\[dap-terminal\\]/ buffers", { output = true })
  local dap_terminals = vim.split(dap_terminals_output.output, "\n")
  local buffers_index = {}
  for _, terminal in ipairs(dap_terminals) do
    local buf_args = vim.split(vim.trim(terminal), " ")
    local buf_index = tonumber(buf_args[1])
    if buf_index ~= nil then
      table.insert(buffers_index, buf_index)
    end
  end
  if #buffers_index > 0 then
    vim.cmd("bd! " .. vim.fn.join(buffers_index, " "))
  end
end

-- Wrapper for QoL
function M.keycode(key)
  return vim.api.nvim_replace_termcodes(key, true, true, true)
end

function M.feedkey(key, mode)
  vim.api.nvim_feedkeys(M.keycode(key), mode, true)
end

function M.augroup(name, opts)
  local final_opts = opts or { clear = true }
  return vim.api.nvim_create_augroup("wenvim_" .. name, final_opts)
end

function M.map(mode, lhs, rhs, opts)
  -- default options
  local final_opts = { noremap = true, silent = true }
  if type(opts) == "string" then
    -- in most case we just want add some description
    final_opts.desc = opts
  elseif type(opts) == "table" then
    -- other case, just take the opts
    final_opts = opts
  end
  vim.keymap.set(mode, lhs, rhs, final_opts)
end


function M.toggle_win_diff()
    if vim.wo.diff then
        vim.cmd("windo diffoff")
    else
        vim.cmd("windo diffthis")
        vim.cmd("windo set wrap")
    end
end

return M
