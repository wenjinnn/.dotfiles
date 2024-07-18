local map = vim.keymap.set
map(
  "n",
  "<leader>S",
  "<cmd>windo set scrollbind!<CR>",
  { silent = true, desc = "Scroll all buffer" }
)
map("n", "<leader>X", "<cmd>only<CR>", { silent = true, desc = "Only" })
map("n", "<leader><leader>X", "<c-^>", { silent = true, desc = "Previous buffer" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- copy/paste to system clipboard
map({ "n", "v" }, "<leader>y", '"+y', { silent = true, desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { silent = true, desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>0", '"0p', { silent = true, desc = "Paste from last yank" })
map("n", "<leader>p", '"+p', { silent = true, desc = "Paste from system clipboard" })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- lazy
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })

map("n", "<leader>l", "<cmd>lopen<cr>", { desc = "Location list" })
map("n", "<leader>q", "<cmd>copen<cr>", { desc = "Quickfix list" })

map("n", "<leader>C", "<cmd>!ctags<cr>", { desc = "Ctags" })

map("n", "<leader>F", "<cmd>lua require'util'.maximize()<cr>", { desc = "Maximize current buffer" })

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
