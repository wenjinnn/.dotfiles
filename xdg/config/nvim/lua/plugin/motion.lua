local later = MiniDeps.later

later(function()
  local map = require('util').map
  require('mini.jump').setup()
  require('mini.jump2d').setup({
    view = {
      dim = true,
      n_steps_ahead = 2,
    },
    mappings = {
      start_jumping = 'sj',
    },
  })
  map({ 'n', 'x', 'o' }, ';', function() MiniJump.jump(nil, false) end, 'Jump forward')
  map({ 'n', 'x', 'o' }, ',', function() MiniJump.jump(nil, true) end, 'Jump backward')
  local function jump2d_single_chatacter() MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end
  map({ 'n', 'x', 'o' }, 'ss', jump2d_single_chatacter, 'Jump2d single chatacter')
  local function jump2d_query() MiniJump2d.start(MiniJump2d.builtin_opts.query) end
  map({ 'n', 'x', 'o' }, 'sq', jump2d_query, 'Jump2d query')
end)
