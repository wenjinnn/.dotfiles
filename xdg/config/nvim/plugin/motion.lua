local util = wenvim.util
local map = util.map
local later = util.later

later(function()
  require('mini.jump').setup()
  require('mini.jump2d').setup({ view = { dim = true, n_steps_ahead = 2 } })
  local function jump2d_single_chatacter() MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end
  map({ 'n', 'x', 'o' }, 'ss', jump2d_single_chatacter, 'Jump2d single chatacter')
  local function jump2d_query() MiniJump2d.start(MiniJump2d.builtin_opts.query) end
  map({ 'n', 'x', 'o' }, 'sq', jump2d_query, 'Jump2d query')
  local function jump2d_line_start() MiniJump2d.start(MiniJump2d.builtin_opts.line_start) end
  map({ 'n', 'x', 'o' }, 'sl', jump2d_line_start, 'Jump2d line start')
  local function jump2d_word_start() MiniJump2d.start(MiniJump2d.builtin_opts.word_start) end
  map({ 'n', 'x', 'o' }, 'sw', jump2d_word_start, 'Jump2d word start')
end)
