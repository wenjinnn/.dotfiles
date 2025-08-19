local augroup = require('util').augroup
local au = vim.api.nvim_create_autocmd

-- Check if we need to reload the file when it changed
au({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup('checktime'),
  callback = function()
    if vim.o.buftype ~= 'nofile' then vim.cmd('checktime') end
  end,
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

-- fcitx5 auto switch to default input method
if vim.fn.executable('fcitx5') == 1 then
  au({ 'InsertLeave' }, {
    group = augroup('fcitx5'),
    pattern = '*',
    callback = function() vim.cmd("silent call system('fcitx5-remote -c')") end,
  })
end
