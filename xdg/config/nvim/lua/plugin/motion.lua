local add, later = MiniDeps.add, MiniDeps.later
local map = vim.keymap.set
later(function()
  add({ source = "folke/flash.nvim" })
  local flash = require("flash")
  flash.setup({
    label = {
      uppercase = false,
    },
  })
  -- copied from mini.jump2d, make flash jump work like it
  local revert_cr = function() map("n", "<CR>", "<CR>", { buffer = true }) end
  local au = function(event, pattern, callback, desc)
    local flash_group = require("util").augroup("flash")
    vim.api.nvim_create_autocmd(event, { pattern = pattern, group = flash_group, callback = callback, desc = desc })
  end
  au("FileType", "qf", revert_cr, "Revert <CR>")
  au("CmdwinEnter", "*", revert_cr, "Revert <CR>")

  map({ "n", "x", "o" }, "<CR>", flash.jump, { desc = "Flash jump" })
  map({ "n", "x", "o" }, "<S-CR>", flash.treesitter, { desc = "Flash treesitter" })
  map("o", "r", flash.remote, { desc = "Remote flash" })
  map({ "o", "x" }, "R", flash.treesitter_search, { desc = "Flash treesitter search" })
  map("c", "<c-s>", flash.toggle, { desc = "Toggle flash search" })
  map("n", "<leader>*", function()
    require("flash").jump({ pattern = vim.fn.expand("<cword>") })
  end, { desc = "Flash jump cursor word" })
end)
