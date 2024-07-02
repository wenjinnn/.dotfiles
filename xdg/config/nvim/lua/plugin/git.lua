local not_vscode = require("util").not_vscode
-- git
return {
  {
    "echasnovski/mini.diff",
    event = "BufReadPre",
    cond = not_vscode,
    opts = {},
    keys = {
      {
        "<leader>go",
        "<cmd>lua MiniDiff.toggle_overlay()<CR>",
        desc = "Git Toggle Overlay",
      },
    },
  },
  {
    "echasnovski/mini-git",
    main = "mini.git",
    event = "BufReadPre",
    cond = not_vscode,
    opts = {},
    keys = {
      {
        "<leader>gc",
        "<cmd>lua MiniGit.show_at_cursor()<CR>",
        desc = "Git Show At Cursor",
      },
      {
        "<leader>gh",
        "<cmd>lua MiniGit.show_range_history()<CR>",
        mode = { "n", "v" },
        desc = "Git Show Range History",
      },
      {
        "<leader>gd",
        "<cmd>lua MiniGit.show_diff_source()<CR>",
        mode = { "n", "v" },
        desc = "Git Show Diff Source",
      },
    },
  },
}
