-- my nvim config write in lua
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
vim.cmd.packadd('old-zip')


-- Set the clipboard provider synchronously at startup, before any plugin,
-- autocmd or RPC client (vscode-neovim/firenvim/preview) can touch the "+"
-- register. Neovim resolves the provider on first register access and locks
-- it in for the whole session. In WSL auto-detection picks wl-copy (WSLg
-- exports WAYLAND_DISPLAY and the nvim wrapper puts wl-copy on PATH), which
-- then fails because the Wayland socket lives under /mnt/wslg/runtime-dir,
-- not $XDG_RUNTIME_DIR.
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

require('wenvim').setup()

vim.schedule(function()
  vim.diagnostic.config({ virtual_text = true })
  if vim.g.vscode then vim.notify = vscode.notify end
  vim.cmd('packadd nvim.undotree')
  vim.cmd('packadd nvim.difftool')
end)
