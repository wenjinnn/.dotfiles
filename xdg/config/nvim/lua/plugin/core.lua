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
    event = "CmdLineEnter",
    build = "sh ./install.sh 1",
    opts = {
      repl_enable = { "Lua_nvim" },
      selected_interpreters = { "Lua_nvim" },
      live_mode_toggle = "enable",
    },
    keys = {
      { "<leader>rs", "<Plug>SnipRun", desc = "Run snip", mode = { "n", "v" } },
      { "<leader>rS", "<Plug>SnipRunOperator", desc = "Run snip operator" },
    },
  },
}
