local later = MiniDeps.later
local map = vim.keymap.set

-- git
later(function()
  require("mini.git").setup()
  map({ "n", "x" }, "<leader>ga", function()
      MiniGit.show_at_cursor()
    end,
    { desc = "Git show at cursor" })
  map({ "n", "v" }, "<leader>gh",
    function()
      MiniGit.show_range_history()
    end,
    { desc = "Git show range history" })
  map({ "n", "v" }, "<leader>gd",
    function()
      MiniGit.show_diff_source()
    end,
    { desc = "Git show diff source" })
end)

later(function()
  require("mini.diff").setup()
  map("n", "<leader>go",
    function()
      MiniDiff.toggle_overlay()
    end,
    { desc = "Git toggle overlay" })
end)
