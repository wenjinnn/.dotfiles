local M = {}

-- make repeatable keymap
function M.make_repeatable_keymap(mode, lhs, rhs)
  vim.validate({
    mode = { mode, { "string", "table" } },
    rhs = { rhs, { "string", "function" }, lhs = { name = "string" } },
  })
  if not vim.startswith(lhs:lower(), "<plug>") then
    error("`lhs` should start with `<Plug>` or `<plug>`, given: " .. lhs)
  end
  vim.keymap.set(mode, lhs, function()
    rhs()
    vim.fn["repeat#set"](vim.api.nvim_replace_termcodes(lhs, true, true, true))
  end)
  return lhs
end

-- test is in vscode
function M.in_vscode()
  return vim.g.vscode
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
  end
end

function M.setup_term_opt()
  vim.opt_local.number = false
  vim.opt_local.signcolumn = "no"
  vim.opt_local.relativenumber = false
  vim.opt_local.spell = false
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

function M.feedkey(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

function M.augroup(name, opts)
  local final_opts = opts or { clear = true }
  return vim.api.nvim_create_augroup("wenvim_" .. name, final_opts)
end

function M.map(mode, lhs, rhs, opts)
  local final_opts = {}
  if type(opts) == "string" then
    final_opts.desc = opts
  elseif type(opts) == "table" then
    final_opts = opts
  end
  vim.keymap.set(mode, lhs, rhs, final_opts)
end

return M
