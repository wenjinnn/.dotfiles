local opt = vim.opt

opt.errorbells = false
opt.breakindent = true
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"
opt.jumpoptions = "view"
opt.formatoptions = "jcroqlnt"
opt.linebreak = true
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.inccommand = "nosplit"
opt.cmdheight = 1
opt.showcmd = true
if vim.g.started_by_firenvim ~= nil then
  opt.laststatus = 0
else
  opt.laststatus = 2
end
opt.number = true
opt.signcolumn = "yes"
opt.relativenumber = true
opt.cursorline = true
opt.virtualedit = { "block", "onemore" }
-- ignore filetype when file search
opt.wildignore:append({
  "*/tmp/*",
  "*.so",
  "*.swp",
  "*.png",
  "*.jpg",
  "*.jpeg",
  "*.gif",
  "*.class",
  "*.pyc",
  "*.pyd",
})
-- code indent
opt.cindent = true
opt.cinoptions = { "g0", ":0", "N-s", "(0" }
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
opt.spelllang = { "en", "cjk" }
opt.spelloptions:append("noplainbuffer")

opt.list = true
opt.listchars = {
  tab = ">-",
  precedes = "«",
  extends = "»",
  trail = "·",
  lead = "·",
  nbsp = "␣",
  conceal = "_",
}

opt.undofile = true
opt.undolevels = 10000
opt.wrap = true
opt.mouse = "a"

-- search
opt.ignorecase = true

opt.autowrite = true
opt.autowriteall = true
opt.confirm = true
opt.updatetime = 500
opt.fileencodings:append({ "gbk", "cp936", "gb2312", "gb18030", "big5", "euc-jp", "euc-kr", "prc" })
opt.termguicolors = true
opt.completeopt = { "menu", "menuone", "noinsert" }
opt.pumheight = 20
opt.shortmess:append({ I = true })
opt.sessionoptions:append({ "winpos", "globals", "skiprtp" })

opt.wildmode = "longest:full,full"
opt.winminwidth = 5
opt.smoothscroll = true

opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.require'util'.foldexpr()"
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

if vim.g.vscode then
  vim.notify = require("vscode-neovim").notify
end
