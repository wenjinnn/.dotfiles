local in_vscode = require("util").in_vscode
if in_vscode() then
  return
end
local add, later = MiniDeps.add, MiniDeps.later
later(function()
  add({ source = "rafamadriz/friendly-snippets" })
  require("mini.completion").setup()
  local gen_loader = require("mini.snippets").gen_loader
  require("mini.snippets").setup({
    snippets = {
      -- Load custom file with global snippets first (adjust for Windows)
      gen_loader.from_file("~/.config/nvim/snippets/global.json"),
      -- Load snippets based on current language by reading files from
      -- "snippets/" subdirectories from 'runtimepath' directories.
      gen_loader.from_lang(),
    },
  })
end)
