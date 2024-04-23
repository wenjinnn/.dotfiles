local not_vscode = require("util").not_vscode
-- git
return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    cond = not_vscode,
    keys = {
      -- Navigation
      {
        "]c",
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            require("gitsigns").nav_hunk("next")
          end
        end,
        desc = "Next Hunk",
      },
      {
        "[c",
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            require("gitsigns").nav_hunk("prev")
          end
        end,
        desc = "Prev Hunk",
      },
      -- Actions
      {
        "<leader>gs",
        "<cmd>Gitsigns stage_hunk<CR>",
        mode = { "n", "v" },
        desc = "Gitsigns Stage Hunk",
      },
      {
        "<leader>gr",
        "<cmd>Gitsigns reset_hunk<CR>",
        mode = { "n", "v" },
        desc = "Gitsigns Reset Hunk",
      },
      {
        "<leader>gS",
        "<cmd>Gitsigns stage_buffer<CR>",
        desc = "Gitsigns Stage Buffer",
      },
      {
        "<leader>gu",
        "<cmd>Gitsigns undo_stage_hunk<CR>",
        desc = "Gitsigns Undo Stage Buffer",
      },
      {
        "<leader>gR",
        "<cmd>Gitsigns reset_buffer<CR>",
        desc = "Gitsigns Reset Buffer",
      },
      {
        "<leader>gp",
        "<cmd>Gitsigns preview_hunk<CR>",
        desc = "Gitsigns Preview Hunk",
      },
      {
        "<leader>gb",
        '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',
        desc = "Gitsigns Full Blame Line",
      },
      {
        "<leader>gB",
        "<cmd>Gitsigns toggle_current_line_blame<CR>",
        desc = "Gitsigns Toggle Current Line Blame",
      },
      {
        "<leader>gd",
        "<cmd>Gitsigns diffthis<CR>",
        desc = "Gitsigns Diffthis",
      },
      {
        "<leader>gD",
        '<cmd>lua require"gitsigns".diffthis("~")<CR>',
        desc = "Gitsigns Diffthis Prev Commit",
      },
      {
        "<leader>gt",
        "<cmd>Gitsigns toggle_deleted<CR>",
        desc = "Gitsigns Toggle Deleted",
      },
      -- Text object
      {
        "ih",
        ":<C-U>Gitsigns select_hunk<CR>",
        mode = { "o", "x" },
        desc = "Gitsigns Select Hunk",
      },
    },
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 500,
        },
      })
    end,
  },
  { "tpope/vim-fugitive", event = "CmdLineEnter" },
}
