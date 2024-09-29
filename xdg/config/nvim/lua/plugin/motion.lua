local later = MiniDeps.later
later(function()
  require("mini.jump").setup()
  require("mini.jump2d").setup({
    view = {
      -- Whether to dim lines with at least one jump spot
      dim = true,
    },
  })
  vim.keymap.set(
    "n", "<CR>",
    "<Cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.query)<CR>"
  )
end)
