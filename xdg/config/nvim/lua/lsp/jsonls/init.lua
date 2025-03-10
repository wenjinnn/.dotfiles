local M = {}
M.settings = {
  json = {
    schemas = require('schemastore').json.schemas(),
    validate = { enable = true },
  },
}
return M
