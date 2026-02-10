local opt = vim.opt

opt.breakindent = true
opt.linebreak = true
opt.number = true
opt.signcolumn = 'yes'
opt.relativenumber = true
opt.cursorline = true
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

opt.autowrite = true
opt.autowriteall = true
opt.confirm = true
opt.updatetime = 500
opt.fileencodings:append({ 'gbk', 'cp936', 'gb2312', 'gb18030', 'big5', 'euc-jp', 'euc-kr', 'prc' })
opt.termguicolors = true
opt.completeopt = { 'menuone', 'noselect', 'fuzzy', 'popup' }
opt.pumheight = 20
opt.sessionoptions:remove({ 'blank' })
opt.smoothscroll = true
opt.winborder = 'single'
opt.diffopt:append({ 'algorithm:histogram', 'indent-heuristic' })
opt.foldlevel = 99
opt.exrc = true

vim.schedule(function()
  vim.diagnostic.config({ virtual_text = true })
  if vim.g.vscode then vim.notify = require('vscode-neovim').notify end
  if vim.fn.has('nvim-0.12') == 1 then
    vim.cmd('packadd nvim.undotree')
    opt.pumborder = 'single'
    opt.completeopt:append({ 'nearest' })
  end

  opt.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus'
  -- Copy/Paste when using wsl
  if vim.fn.has('wsl') == 1 then
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
end)
