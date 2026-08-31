--- AUTOCMD
local augroup = wenvim.util.augroup
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
  callback = function()
    vim.b.miniindentscope_disable = true
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
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

-- close floating windows with 'q'
au('BufWinEnter', {
  group = augroup('close_float_win_with_q'),
  callback = function(ev)
    local win = vim.api.nvim_get_current_win()
    local rhs = function() vim.api.nvim_win_close(win, true) end
    local opts = { buffer = true, nowait = true, unique = true }
    if wenvim.util.is_floating_win(ev.buf) then pcall(vim.keymap.set, 'n', 'q', rhs, opts) end
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
-- set up highlights after colorscheme
au({ 'ColorScheme' }, {
  group = augroup('colorscheme'),
  callback = function() wenvim.color.setup_hl() end,
})

-- Track the last 20 atoms.
local atom_ring = {} ---@type vim.event.cmdatom.data[]
vim.api.nvim_create_autocmd('CmdAtom', {
  callback = function(ev)
    -- Skip this mapping itself, and cmdwin edits.
    if ev.data.lhs ~= ' ' and vim.fn.getcmdwintype() == '' then
      atom_ring[#atom_ring + 1] = ev.data
      if #atom_ring > 20 then table.remove(atom_ring, 1) end
    end
  end,
})
-- [count]<space> shows a cmdwin where the user can edit/save the last [count] atoms as a "macro".
-- <space> (no count) replays it.
vim.keymap.set('n', '<leader>@', function()
  local count = vim.v.count
  -- CmdAtom is deferred; schedule it so pending events land in the ring first.
  vim.schedule(function()
    count = math.min(count, #atom_ring)
    if count == 0 then -- Replay the saved macro.
      for _, step in ipairs(vim.g.atom_macro or {}) do
        vim.api.nvim_feedkeys(vim.keycode(step.keys or step.lhs), step.keys and 'n' or 'm', false)
      end
      return
    end
    local parts = {}
    for i = #atom_ring - count + 1, #atom_ring do
      local a = atom_ring[i]
      local keys = a.keys or ('%s%s'):format(a.count or '', a.lhs)
      local field = a.keys and 'keys' or 'lhs'
      parts[#parts + 1] = ('{%s=%q},'):format(field, vim.fn.keytrans(keys))
    end
    local cmd = ('lua vim.g.atom_macro = { %s }'):format(table.concat(parts, ' '))
    -- Draft it on the cmdline; CTRL-F opens the cmdwin to edit it.
    vim.api.nvim_feedkeys((':%s%s'):format(cmd, vim.keycode('<C-f>')), 'n', false)
  end)
end)
