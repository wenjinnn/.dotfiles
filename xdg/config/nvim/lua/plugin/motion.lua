local add, later = MiniDeps.add, MiniDeps.later
local map = require("util").map
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

  map({ "n", "x", "o" }, "<CR>", flash.jump, "Flash jump")
  map({ "n", "x", "o" }, "<S-CR>", flash.treesitter, "Flash treesitter")
  map("o", "r", flash.remote, "Remote flash")
  map({ "o", "x" }, "R", flash.treesitter_search, "Flash treesitter search")
  map("c", "<c-s>", flash.toggle, "Toggle flash search")
  map("n", "<leader>*", function()
      require("flash").jump({ pattern = vim.fn.expand("<cword>") })
    end,
    "Flash jump cursor word")
end)
