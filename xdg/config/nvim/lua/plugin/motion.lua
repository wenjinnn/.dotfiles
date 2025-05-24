local later = MiniDeps.later

later(function()
  local map = require('util').map
  require('mini.jump').setup()
  require('mini.jump2d').setup({ view = { dim = true } })
  map({ 'n', 'x', 'o' }, ';', function() MiniJump.jump(nil, false) end, 'Jump forward')
  map({ 'n', 'x', 'o' }, ',', function() MiniJump.jump(nil, true) end, 'Jump backward')
  -- Personally, I prefer using mini.jump2d's query. With it, the number of keystrokes is almost constant
  local function jump2d_query() MiniJump2d.start(MiniJump2d.builtin_opts.query) end
  map({ 'n', 'x', 'o' }, '<CR>', jump2d_query, 'Jump2d query')
end)
