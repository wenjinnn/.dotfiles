local M = {}
function M.setup()
  _G.wenvim = {
    util = require('wenvim.util'),
    lsp = require('wenvim.lsp'),
    color = require('wenvim.color'),
  }
end

return M
