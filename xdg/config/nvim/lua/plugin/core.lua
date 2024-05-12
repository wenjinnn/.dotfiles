return {
  -- base plugin
  { "nvim-lua/plenary.nvim", lazy = true },
  { "tpope/vim-repeat", event = "BufRead", lazy = true },
  {
    "echasnovski/mini.basics",
    event = "VeryLazy",
    lazy = true,
    opts = {
      mappings = {
        windows = false,
      },
    },
  },
  { "echasnovski/mini.extra", lazy = true, opts = {} },
}
