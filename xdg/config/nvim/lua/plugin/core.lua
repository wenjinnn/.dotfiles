return {
  -- base plugin
  { "nvim-lua/plenary.nvim", lazy = true },
  { "tpope/vim-repeat", event = "BufRead", lazy = true },
  {
    "echasnovski/mini.basics",
    event = "VeryLazy",
    lazy = true,
    opts = {
      basic = true,
      extra_ui = true,
      win_borders = "solid",
      mappings = {
        windows = false,
      },
    },
  },
  { "echasnovski/mini.extra", lazy = true, opts = {} },
}
