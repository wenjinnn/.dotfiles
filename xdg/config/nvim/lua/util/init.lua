local M = {}
-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  local modes = type(mode) == "string" and { mode } or mode

  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

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
      \ cspell
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
      \ marksman
      \ vuels
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
    ]])
  end
end

-- test is in vscode
function M.not_vscode()
  return not vim.g.vscode
end

return M
