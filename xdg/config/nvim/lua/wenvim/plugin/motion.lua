local map = require('wenvim.util').map
require('mini.jump').setup()
require('mini.jump2d').setup({ view = { dim = true, n_steps_ahead = 2 } })
map({ 'n', 'x', 'o' }, ';', function() MiniJump.smart_jump(false) end, 'Jump forward')
map({ 'n', 'x', 'o' }, ',', function() MiniJump.smart_jump(true) end, 'Jump backward')
local function jump2d_single_chatacter() MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end
map({ 'n', 'x', 'o' }, 'ss', jump2d_single_chatacter, 'Jump2d single chatacter')
local function jump2d_query() MiniJump2d.start(MiniJump2d.builtin_opts.query) end
map({ 'n', 'x', 'o' }, 'sq', jump2d_query, 'Jump2d query')
