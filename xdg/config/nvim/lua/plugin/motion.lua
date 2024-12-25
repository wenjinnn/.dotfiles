local later = MiniDeps.later
later(function()
  require("mini.jump").setup()
  require("mini.jump2d").setup({ view = { dim = true } })
  vim.keymap.set(
    { "n", "x", "o" }, "<CR>",
    "<Cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.query)<CR>"
  )
end)
