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

-- close some filetypes with <q>
au('FileType', {
  group = augroup('close_with_q'),
  pattern = {
    'PlenaryTestPopup',
    'help',
    'lspinfo',
    'dap-float',
    'dap-repl',
    'man',
    'notify',
    'qf',
    'query',
    'git',
    'spectre_panel',
    'startuptime',
    'tsplayground',
    'checkhealth',
    'httpResult',
    'dbout',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
})

-- wrap vim diff buffer
au({ 'VimEnter' }, {
  group = augroup('vim_enter'),
  pattern = '*',
  callback = function(event)
    if vim.o.diff then vim.wo.wrap = true end
  end,
})

-- fcitx5 auto switch to default input method
if vim.fn.has('fcitx5') == 1 then
  au({ 'InsertLeave' }, {
    group = augroup('fcitx5'),
    pattern = '*',
    callback = function() vim.cmd("silent call system('fcitx5-remote -c')") end,
  })
end

-- Copy/Paste when using wsl
au('VimEnter', {
  group = augroup('clipboard'),
  callback = function()
    if vim.fn.has('wsl') == 1 then
      vim.g.clipboard = {
        name = 'WslClipboard',
        copy = {
          ['+'] = 'clip.exe',
          ['*'] = 'clip.exe',
        },
        paste = {
          ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
          ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        },
        cache_enabled = 0,
      }
    end
  end,
})

-- terminal buffer specific options
au({ 'TermEnter', 'TermOpen' }, {
  group = augroup('terminal_buffer'),
  pattern = '*',
  callback = require('util').setup_term_opt,
})

-- work with bigfile that bigger then 5MB
-- modified from folke snacks.nvim
local bigfile_size = 5 * 1024 * 1024
vim.filetype.add({
  pattern = {
    ['.*'] = {
      function(path, buf)
        return vim.bo[buf]
            and vim.bo[buf].filetype ~= 'bigfile'
            and path
            and vim.fn.getfsize(path) > bigfile_size
            and 'bigfile'
          or nil
      end,
    },
  },
})

au({ 'FileType' }, {
  group = augroup('bigfile', { clear = true }),
  pattern = 'bigfile',
  callback = function(event)
    local buf = event.buf
    local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':p:~:.')
    local ft = vim.filetype.match({ buf = buf }) or ''
    vim.notify(string.format('Big file detected `%s`.', path), vim.log.levels.WARN)
    vim.api.nvim_buf_call(buf, function()
      vim.schedule(function() vim.bo[buf].syntax = ft end)
    end)
  end,
})
