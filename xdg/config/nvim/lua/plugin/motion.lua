local add, later = MiniDeps.add, MiniDeps.later
local map = vim.keymap.set
later(function()
  add({ source = "folke/flash.nvim" })
  require("flash").setup({
    label = {
      uppercase = false,
    },
  })
  -- copied from mini.jump2d, make flash jump work like it
  local revert_cr = function() map("n", "<CR>", "<CR>", { buffer = true }) end
  local au = function(event, pattern, callback, desc)
    local flash_group = vim.api.nvim_create_augroup("wenvim_flash", { clear = true })
    vim.api.nvim_create_autocmd(event, { pattern = pattern, group = flash_group, callback = callback, desc = desc })
  end
  au("FileType", "qf", revert_cr, "Revert <CR>")
  au("CmdwinEnter", "*", revert_cr, "Revert <CR>")
  map({ "n", "x", "o" }, "<CR>", function()
    require("flash").jump()
  end, { desc = "Flash jump" })
  map({ "n", "x", "o" }, "<S-CR>", function()
    require("flash").treesitter()
  end, { desc = "Flash treesitter" })
  map("o", "r", function()
    require("flash").remote()
  end, { desc = "Remote flash" })
  map({ "o", "x" }, "R", function()
    require("flash").treesitter_search()
  end, { desc = "Flash treesitter search" })
  map("c", "<c-s>", function()
    require("flash").toggle()
  end, { desc = "Toggle flash search" })
  map("n", "<leader>*", function()
    require("flash").jump({ pattern = vim.fn.expand("<cword>") })
  end, { desc = "Flash jump cursor word" })
end)
