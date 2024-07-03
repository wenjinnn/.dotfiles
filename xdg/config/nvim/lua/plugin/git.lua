local not_vscode = require("util").not_vscode
-- git
return {
  {
    "echasnovski/mini.diff",
    event = "BufRead",
    cond = not_vscode,
    opts = {},
    keys = {
      {
        "<leader>go",
        "<cmd>lua MiniDiff.toggle_overlay()<CR>",
        desc = "Git toggle overlay",
      },
    },
  },
  {
    "echasnovski/mini-git",
    main = "mini.git",
    event = "BufRead",
    cond = not_vscode,
    opts = {},
    keys = {
      {
        "<leader>gc",
        "<cmd>lua MiniGit.show_at_cursor()<CR>",
        desc = "Git show at cursor",
      },
      {
        "<leader>gh",
        "<cmd>lua MiniGit.show_range_history()<CR>",
        mode = { "n", "v" },
        desc = "Git show range history",
      },
      {
        "<leader>gd",
        "<cmd>lua MiniGit.show_diff_source()<CR>",
        mode = { "n", "v" },
        desc = "Git show diff source",
      },
    },
  },
}
