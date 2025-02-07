-- The keymaps here are independent of plugins
-- all the keymap that related to plugin it self are declared after plugin
local util = require("util")
local map = util.map
map("n", "<leader>S", "<cmd>windo set scrollbind!<CR>", "Scroll all buffer")
map("n", "<leader>O", "<cmd>only<CR>", "Only")
map("n", "<leader>X", util.toggle_win_diff, "Diffthis windowed buffers")
map("n", "<leader>R", util.source_all, "Resource all config")
-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- copy/paste to system clipboard
map({ "n", "v" }, "<leader>y", '"+y', "Yank to system clipboard")
map("n", "<leader>Y", '"+Y', "Yank line to system clipboard")
map({ "n", "v" }, "<leader>0", '"0p', "Paste from last yank")
map("n", "<leader>p", '"+p', "Paste from system clipboard")

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", "Keywordprg")
map("n", "<leader>L", "<cmd>lopen<cr>", "Location list")
map("n", "<leader>Q", "<cmd>copen<cr>", "Quickfix list")
map("n", "<leader>]", "<cmd>!ctags<cr>", "Ctags")
if vim.g.vscode then
  local action = function(action, opts)
    return function()
      require("vscode-neovim").action(action, opts)
    end
  end
  map("n", "K", action("editor.action.showHover"))
  map("n", "gd", action("editor.action.peekDefinition"))
  map("n", "gD", action("editor.action.peekDeclaration"))
  map("n", "gh", action("editor.action.showDefinitionPreviewHover"))
  map("n", "gi", action("editor.action.goToImplementation"))
  map("n", "gI", action("editor.showIncomingCalls"))
  map("n", "gO", action("editor.showOutgoingCalls"))
  map("n", "gr", action("editor.action.goToReferences"))
  map("v", "<leader>tt", action("translates.translates", { args = { 1 } }))
  map("n", "<leader>fe", action("workbench.view.explorer"))
  map("n", "<leader>ff", action("workbench.action.quickOpen"))
  map("n", "<leader>fe", action("workbench.view.explorer"))
  map("n", "<leader>ff", action("workbench.view.search"))
  map("n", "<leader>fg", action("workbench.view.search"))
  map("n", "<leader>fb", action("workbench.action.quickOpenPreviousRecentlyUsedEditor"))
  map("n", "[b", action("workbench.action.quickOpenPreviousRecentlyUsedEditor"))
  map("n", "]b", action("workbench.action.quickOpenLeastRecentlyUsedEditor"))
  map("n", "<c-\\><c-\\>", action("workbench.action.terminal.toggleTerminal"))
  map("n", "<leader>mm", action("editor.action.formatDocument"))
  map("v", "<leader>mm", action("editor.action.formatSelection"))
  map({ "n", "v" }, "<leader>ca", action("editor.action.quickFix"))
  map("n", "<leader>x", action("workbench.action.closeActiveEditor"))
end
