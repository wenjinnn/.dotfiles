-- my nvim config write in lua
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require('wenvim').setup()

vim.schedule(function()
  vim.diagnostic.config({ virtual_text = true })
  if vim.g.vscode then vim.notify = vscode.notify end
  vim.cmd('packadd nvim.undotree')
  vim.cmd('packadd nvim.difftool')

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
end)
