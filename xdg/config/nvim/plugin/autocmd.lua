local augroup = require('wenvim.util').augroup
local au = vim.api.nvim_create_autocmd

-- Check if we need to reload the file when it changed
au({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup('checktime'),
  callback = function()
    if vim.o.buftype ~= 'nofile' then vim.cmd('checktime') end
  end,
})

-- terminal buffer specific options
au({ 'TermEnter', 'TermOpen' }, {
  group = augroup('terminal_buffer'),
  pattern = '*',
  callback = function() vim.b.miniindentscope_disable = true end,
})

-- resize splits if window got resized
au({ 'VimResized' }, {
  group = augroup('resize_splits'),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- close floating windows with 'q'
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(win)
    local rhs = function() vim.api.nvim_win_close(win, true) end
    local opts = { buffer = true, nowait = true, unique = true }
    if config.relative ~= '' then pcall(vim.keymap.set, 'n', 'q', rhs, opts) end
  end,
})

-- fcitx5 auto switch to default input method
if vim.fn.executable('fcitx5') == 1 then
  au({ 'InsertLeave' }, {
    group = augroup('fcitx5'),
    pattern = '*',
    callback = function() vim.cmd("silent call system('fcitx5-remote -c')") end,
  })
end
