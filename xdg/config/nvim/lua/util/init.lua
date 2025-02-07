local M = {}

-- We don't want signcolumn, number, spell and indentscope for terminal
function M.setup_term_opt(event)
  vim.opt_local.number = false
  vim.opt_local.signcolumn = "no"
  vim.opt_local.relativenumber = false
  vim.opt_local.spell = false
  vim.b.miniindentscope_disable = true
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

function M.source_all()
    local config_bundles = vim.split(vim.fn.glob(vim.fn.stdpath("config") .. "/**/*.lua"), "\n")
    for _, config in pairs(config_bundles) do
        vim.cmd.source(config)
    end
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
