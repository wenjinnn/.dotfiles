local later = MiniDeps.later
later(function()
  require("mini.jump").setup()
  require("mini.jump2d").setup({
    view = {
      -- Whether to dim lines with at least one jump spot
      dim = true,
    },
  })
end)
