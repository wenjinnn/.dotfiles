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
      mappings = {
        windows = false,
      },
    },
  },
  { "echasnovski/mini.extra", lazy = true, opts = {} },
  { "MunifTanjim/nui.nvim", lazy = true },
  {
    "michaelb/sniprun",
    build = "sh install.sh",
    keys = {
      { "<leader>rs", "<Plug>SnipRun", desc = "Run snip", mode = { "n", "v" } },
      { "<leader>rS", "<Plug>SnipRunOperator", desc = "Run snip operator" },
    },
  },
}
