-- my nvim config write in lua
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

--- OPTIONS
local opt = vim.opt

opt.breakindent = true
opt.linebreak = true
opt.number = true
opt.signcolumn = 'yes'
opt.relativenumber = true
opt.cursorline = true
opt.cursorlineopt = { 'screenline', 'number' }
opt.showmode = false
opt.shortmess:remove({ 'S' })
opt.colorcolumn = '+1'
opt.ruler = false
opt.infercase = true
opt.virtualedit = { 'block', 'onemore' }
-- code indent
opt.cindent = true
opt.smartindent = true
-- tab & space
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.shiftround = true
opt.softtabstop = 4
opt.sidescroll = 10
opt.sidescrolloff = 8
opt.scrolloff = 5

opt.spell = true
opt.spelllang = { 'en', 'cjk' }
opt.spelloptions:append({ 'camel', 'noplainbuffer' })
opt.formatoptions:append({ 'n' })
opt.iskeyword:append({ '-' })

opt.list = true
opt.listchars = {
  tab = '>-',
  precedes = '«',
  extends = '»',
  trail = '·',
  lead = '·',
  nbsp = '␣',
  conceal = '_',
}

opt.undofile = true
opt.undolevels = 10000
opt.wrap = true
opt.mouse = 'a'

-- search
opt.ignorecase = true

opt.switchbuf = { 'usetab', 'uselast' }
opt.autowrite = true
opt.autowriteall = true
opt.confirm = true
opt.updatetime = 500
opt.fileencodings:append({ 'gbk', 'cp936', 'gb2312', 'gb18030', 'big5', 'euc-jp', 'euc-kr', 'prc' })
opt.termguicolors = true
opt.complete:append({ 'kspell' })
opt.completeopt = { 'menuone', 'noselect', 'fuzzy', 'popup', 'nearest' }
opt.pumheight = 20
opt.pumborder = 'single'
opt.sessionoptions:remove({ 'blank' })
opt.smoothscroll = true
opt.winborder = 'single'
opt.diffopt:append({ 'algorithm:histogram', 'indent-heuristic' })
-- linematch algorithm is breaking the functionality of diffget. Disabling this til this issue gets solved. related to:
-- https://github.com/tpope/vim-fugitive/issues/2436 https://github.com/neovim/neovim/issues/35513
opt.diffopt:remove({ 'linematch' })
opt.foldlevel = 99
opt.exrc = true

vim.schedule(function()
  vim.diagnostic.config({ virtual_text = true })
  if vim.g.vscode then vim.notify = require('vscode-neovim').notify end
  vim.cmd('packadd nvim.undotree')
  vim.cmd('packadd nvim.difftool')

  opt.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus'
  -- tmux clipboard first, then ssh, then wsl clipboard
  if vim.env.TMUX then
    vim.g.clipboard = 'tmux'
  elseif not vim.env.SSH_TTY and vim.fn.has('wsl') == 1 then
    -- Copy/Paste when using wsl
    vim.g.clipboard = {
      name = 'WslClipboard',
      copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
      },
      paste = {
        ['+'] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ['*'] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = 0,
    }
  end

  --- KEYMAP
  -- The keymaps here are independent of plugins
  -- all the keymap that related to plugin it self are declared after plugin
  local util = require('wenvim.util')
  local map = util.map
  map('n', '<leader>S', '<cmd>windo set scrollbind!<CR>', 'Scroll all buffer')
  map('n', '<leader>O', '<cmd>only<CR>', 'Only')
  map('n', '<leader>Q', util.toggle_qf, 'Toggle quickfix list')
  map('n', '<leader>L', util.toggle_loc, 'Toggle location list')
  map('n', '<leader>X', util.toggle_win_diff, 'Diffthis windowed buffers')
  map('n', '<leader>R', util.source_all, 'Resource all config')
  map('n', '<leader>U', vim.pack.update, 'Update plugins')

  -- copy/paste to system clipboard
  map({ 'n', 'v' }, '<leader>y', '"+y', 'Yank to system clipboard')
  map('n', '<leader>Y', '"+Y', 'Yank line to system clipboard')
  map({ 'n', 'v' }, '<leader>0', '"0p', 'Paste from last yank')
  map('n', '<leader>p', '"+p', 'Paste from system clipboard')

  --keywordprg
  map('n', '<leader>K', '<cmd>norm! K<cr>', 'Keywordprg')
  map('n', '<leader>]', '<cmd>!ctags<cr>', 'Ctags')
  map('n', '[g', '<cmd>colder<cr>', 'Go to older quickfix list')
  map('n', ']g', '<cmd>cnewer<cr>', 'Go to newer quickfix list')
  map('n', '[n', '<cmd>lolder<cr>', 'Go to older location list')
  map('n', ']n', '<cmd>lnewer<cr>', 'Go to newer location list')

  --- AUTOCMD
  local augroup = util.augroup
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
  au('BufWinEnter', {
    group = augroup('close_float_win_with_q'),
    callback = function(ev)
      local win = vim.api.nvim_get_current_win()
      local rhs = function() vim.api.nvim_win_close(win, true) end
      local opts = { buffer = true, nowait = true, unique = true }
      if util.is_floating_win(ev.buf) then pcall(vim.keymap.set, 'n', 'q', rhs, opts) end
    end,
  })

  -- auto switch input method depending on system
  if vim.fn.executable('fcitx5') == 1 then
    -- fcitx5 auto switch to default input method
    au({ 'InsertLeave' }, {
      group = augroup('fcitx5'),
      pattern = '*',
      callback = function() vim.cmd("silent call system('fcitx5-remote -c')") end,
    })
  elseif vim.fn.has('wsl') == 1 and vim.fn.executable('/mnt/c/im-select.exe') == 1 then
    -- auto switch to default keyboard when in wsl, to make this work
    -- ensure you're having 1033 (USA keyboard) and https://github.com/daipeihust/im-select at C:\
    au({ 'InsertLeave' }, {
      group = augroup('wsl_im'),
      pattern = '*',
      callback = function() vim.cmd("silent call system('/mnt/c/im-select.exe 1033')") end,
    })
  end
  --- COLORSCHEME
  vim.cmd.colorscheme('wenvim-brown')
end)
