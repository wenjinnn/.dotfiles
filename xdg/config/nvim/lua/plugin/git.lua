-- git
return {
  {
    'lewis6991/gitsigns.nvim',
    event = "BufRead",
    cond = not vim.g.vscode,
    keys = {
      -- Navigation
      { ']c',         '&diff ? "]c" : "<cmd>Gitsigns next_hunk<CR>"',        expr = true },
      { '[c',         '&diff ? "[c" : "<cmd>Gitsigns prev_hunk<CR>"',        expr = true },
      -- Actions
      { '<leader>gs', '<cmd>Gitsigns stage_hunk<CR>',                        mode = { 'n', 'v' } },
      { '<leader>gr', '<cmd>Gitsigns reset_hunk<CR>',                        mode = { 'n', 'v' } },
      { '<leader>gS', '<cmd>Gitsigns stage_buffer<CR>' },
      { '<leader>gu', '<cmd>Gitsigns undo_stage_hunk<CR>' },
      { '<leader>gR', '<cmd>Gitsigns reset_buffer<CR>' },
      { '<leader>gp', '<cmd>Gitsigns preview_hunk<CR>' },
      { '<leader>gb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>' },
      { '<leader>gB', '<cmd>Gitsigns toggle_current_line_blame<CR>' },
      { '<leader>gd', '<cmd>Gitsigns diffthis<CR>' },
      { '<leader>gD', '<cmd>lua require"gitsigns".diffthis("~")<CR>' },
      { '<leader>gt', '<cmd>Gitsigns toggle_deleted<CR>' },
      -- Text object
      { 'ih',         ':<C-U>Gitsigns select_hunk<CR>',                      mode = { 'o', 'x' } },
    },
    config = function()
      require('gitsigns').setup({
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 500
        },
      })
    end
  },
  { 'tpope/vim-fugitive', event = "CmdLineEnter" }
}
