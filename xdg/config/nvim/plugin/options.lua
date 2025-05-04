local opt = vim.opt

opt.breakindent = true
opt.grepprg = 'rg --vimgrep'
opt.grepformat = '%f:%l:%c:%m'
opt.formatoptions = 'jcroqlnt'
opt.linebreak = true
opt.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus'
opt.inccommand = 'nosplit'
opt.showcmd = true
opt.number = true
opt.signcolumn = 'yes'
opt.relativenumber = true
opt.cursorline = true
opt.virtualedit = { 'block', 'onemore' }
-- ignore filetype when file search
opt.wildignore:append({
  '*/tmp/*',
  '*.so',
  '*.swp',
  '*.png',
  '*.jpg',
  '*.jpeg',
  '*.gif',
  '*.class',
  '*.pyc',
  '*.pyd',
})
-- code indent
opt.cindent = true
opt.cinoptions = { 'g0', ':0', 'N-s', '(0' }
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
opt.completeopt = { 'menuone', 'noselect', 'fuzzy' }
opt.pumheight = 20
opt.sessionoptions:remove({ 'blank' })
opt.wildmode = 'longest:full,full'
opt.shortmess:append({ I = true })
opt.winminwidth = 5
opt.smoothscroll = true
opt.winborder = 'single'

opt.foldlevel = 99
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.diagnostic.config({ virtual_text = true })
if vim.g.vscode then vim.notify = require('vscode-neovim').notify end

if vim.fn.has('nvim-0.12') == 1 then require('vim._extui').enable({}) end
