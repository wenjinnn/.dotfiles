return {
  -- motion
  {
    "folke/flash.nvim",
    event = "BufRead",
    opts = {
      label = {
        uppercase = false,
      },
    },
    config = function(_, opts)
      require("flash").setup(opts)
      -- copied from mini.jump2d, make flash jump work like it
      local revert_cr = function() vim.keymap.set("n", "<CR>", "<CR>", { buffer = true }) end
      local au = function(event, pattern, callback, desc)
        vim.api.nvim_create_autocmd(event, { pattern = pattern, group = augroup, callback = callback, desc = desc })
      end
      au("FileType", "qf", revert_cr, "Revert <CR>")
      au("CmdwinEnter", "*", revert_cr, "Revert <CR>")
    end,
    keys = {
      {
        "<CR>",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      {
        "<S-CR>",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Flash treesitter search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle flash search",
      },
      {
        "<leader>*",
        mode = { "n" },
        function()
          require("flash").jump({ pattern = vim.fn.expand("<cword>") })
        end,
        desc = "Flash jump cursor word",
      },
    },
  },
}
