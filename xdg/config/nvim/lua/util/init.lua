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

-- download mason package on fresh init
function M.mason_package_init()
  local installed_pkgs = require("mason-registry").get_installed_packages()
  local install_confirm = ""
  if #installed_pkgs == 0 then
    install_confirm =
      vim.fn.input("No package installed yet, install default package now ? (via Mason) Y/n = ")
  end
  install_confirm = string.lower(install_confirm)
  if install_confirm == "y" then
    vim.cmd([[
      MasonInstall
      \ typescript-language-server
      \ dot-language-server
      \ stylua
      \ vim-language-server
      \ emmet-ls
      \ html-lsp
      \ prettier
      \ sqlls
      \ python-lsp-server
      \ yaml-language-server
      \ lemminx
      \ luaformatter
      \ lua-language-server
      \ volar
      \ jdtls
      \ vscode-java-decompiler
      \ java-debug-adapter
      \ java-test
      \ google-java-format
      \ pyright
      \ bash-language-server
      \ eslint-lsp
      \ rust-analyzer
      \ clang-format
      \ taplo
      \ clangd
      \ codelldb
      \ cpplint
      \ cpptools
      \ gradle-language-server
      \ glow
      \ sonarlint-language-server
      \ jq
      \ jsonls
      \ vale
      \ vale_ls
    ]])
  end
end

-- test is in vscode
function M.not_vscode()
  return not vim.g.vscode
end

M.skip_foldexpr = {} ---@type table<number,boolean>
M.skip_buftype = { help = true, terminal = true } ---@type table<string,boolean>
local skip_check = assert(vim.uv.new_check())

function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()

  -- still in the same tick and no parser
  if M.skip_foldexpr[buf] then
    return "0"
  end

  -- don't use treesitter folds for non-file buffers
  if M.skip_buftype[vim.bo[buf].buftype] then
    return "0"
  end

  -- as long as we don't have a filetype, don't bother
  -- checking if treesitter is available (it won't)
  if vim.bo[buf].filetype == "" then
    return "0"
  end

  local ok = pcall(vim.treesitter.get_parser, buf)

  if ok then
    return vim.treesitter.foldexpr()
  end

  -- no parser available, so mark it as skip
  -- in the next tick, all skip marks will be reset
  M.skip_foldexpr[buf] = true
  skip_check:start(function()
    M.skip_foldexpr = {}
    skip_check:stop()
  end)
  return "0"
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
  end
end

M._maximized = nil
-- copied from https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/toggle.lua#L108
---@param state boolean?
function M.maximize(state)
  if state == (M._maximized ~= nil) then
    return
  end
  if M._maximized then
    for _, opt in ipairs(M._maximized) do
      vim.o[opt.k] = opt.v
    end
    M._maximized = nil
    vim.cmd("wincmd =")
  else
    M._maximized = {}
    local function set(k, v)
      table.insert(M._maximized, 1, { k = k, v = vim.o[k] })
      vim.o[k] = v
    end
    set("winwidth", 999)
    set("winheight", 999)
    set("winminwidth", 10)
    set("winminheight", 4)
    vim.cmd("wincmd =")
  end
  -- `QuitPre` seems to be executed even if we quit a normal window, so we don't want that
  -- `VimLeavePre` might be another consideration? Not sure about differences between the 2
  vim.api.nvim_create_autocmd("ExitPre", {
    once = true,
    group = vim.api.nvim_create_augroup("wenvim_restore_max_exit_pre", { clear = true }),
    desc = "Restore width/height when close Neovim while maximized",
    callback = function()
      M.maximize(false)
    end,
  })
end

function M.setup_term_opt()
  local ol = vim.opt_local
  ol.number = false
  ol.signcolumn = "no"
  ol.relativenumber = false
  ol.spell = false
end

return M
