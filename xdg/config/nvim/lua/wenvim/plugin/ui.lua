if vim.g.vscode then return end

local now, later = MiniDeps.now, MiniDeps.later
local map = require('wenvim.util').map

-- Icons
now(function()
  require('mini.icons').setup()
  MiniIcons.mock_nvim_web_devicons()
end)

-- line
now(function()
  require('mini.statusline').setup()
  require('mini.tabline').setup()
end)

-- Starter should load immediately
now(function()
  local starter = require('mini.starter')
  starter.setup({
    items = {
      starter.sections.sessions(5, true),
      starter.sections.recent_files(5, true, true),
      starter.sections.recent_files(5, false, true),
      starter.sections.builtin_actions(),
      { name = 'Switch', action = function() vim.cmd('Obsidian quick_switch') end, section = 'Note' },
      { name = 'Search', action = function() vim.cmd('Obsidian search') end, section = 'Note' },
      { name = 'Dailies', action = function() vim.cmd('Obsidian dailies') end, section = 'Note' },
      { name = 'New', action = function() vim.cmd('Obsidian new') end, section = 'Note' },
    },
  })
end)

later(function()
  require('mini.indentscope').setup({
    draw = {
      animation = require('mini.indentscope').gen_animation.none(),
    },
  })
end)

-- Just use mini.notify for LSP process, because it could have lot message in the sametime
-- so command line is not enough
later(function()
  require('mini.notify').setup()
  map('n', '<leader>N', MiniNotify.clear, 'Notify clear')
  map('n', '<leader>n', MiniNotify.show_history, 'Notify show history')
end)

-- colors
later(function()
  local hipatterns = require('mini.hipatterns')
  local hi_words = require('mini.extra').gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      fix = hi_words({ 'FIX', 'Fix', 'fix' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),
      done = hi_words({ 'DONE', 'Done', 'done' }, 'MiniHipatternsNote'),
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- clue with some custom postkeys, mostly for zl zh and dap
later(function()
  local miniclue = require('mini.clue')
  local z_post_keys = { zl = 'z', zh = 'z', zL = 'z', zH = 'z' }
  local clue_z_keys = miniclue.gen_clues.z()
  for _, v in ipairs(clue_z_keys) do
    local postkey = z_post_keys[v.keys]
    if postkey then v.postkeys = postkey end
  end
  require('mini.clue').setup({
    triggers = {
      -- Leader triggers
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },
      -- Built-in completion
      { mode = 'i', keys = '<C-x>' },
      -- `g` key
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },
      -- Marks
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },
      -- Registers
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },
      -- Window commands
      { mode = 'n', keys = '<C-w>' },
      -- `z` key
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },
      -- mini.bracketed
      { mode = 'n', keys = ']' },
      { mode = 'n', keys = '[' },
      { mode = 'n', keys = '\\' },
      -- Operator-pending mode key
      { mode = 'o', keys = 'a' },
      { mode = 'o', keys = 'i' },
    },
    clues = {
      -- Enhance this by adding descriptions for <Leader> mapping groups
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      clue_z_keys,
      -- nvim-dap
      { mode = 'n', keys = '<Leader>dC', postkeys = '<Leader>d' },
      { mode = 'n', keys = '<Leader>do', postkeys = '<Leader>d' },
      { mode = 'n', keys = '<Leader>dp', postkeys = '<Leader>d' },
      { mode = 'n', keys = '<Leader>di', postkeys = '<Leader>d' },
      { mode = 'n', keys = '<Leader>dO', postkeys = '<Leader>d' },
      { mode = 'n', keys = '<Leader>de', postkeys = '<Leader>d' },
    },
  })
end)
