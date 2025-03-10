local M = {}

function M.setup()
  for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath('config') .. '/lua/plugin', [[v:val =~ '\.lua$']])) do
    local module = file:gsub('%.lua$', '')
    if module ~= 'init' then require('plugin.' .. module) end
  end
end

return M
