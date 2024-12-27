local M = {}

function M.setup_term_opt(event)
  local bufnr = event.buf
  vim.bo[bufnr].number = false
  vim.bo[bufnr].signcolumn = "no"
  vim.bo[bufnr].relativenumber = false
  vim.bo[bufnr].spell = false
  vim.b[bufnr].miniindentscope_disable = true
end

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
  local final_opts = { noremap = true, silent = true }
  if type(opts) == "string" then
    final_opts.desc = opts
  elseif type(opts) == "table" then
    final_opts = opts
  end
  vim.keymap.set(mode, lhs, rhs, final_opts)
end

return M
