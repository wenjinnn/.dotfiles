return {
  -- rest client
  {
    'NTBBloodbath/rest.nvim',
    cond = not vim.g.vscode,
    config = function()
      require('rest-nvim').setup()
    end
  },
  {
    'nvim-orgmode/orgmode',
    cond = not vim.g.vscode,
    config = function()
      local config = {
        org_agenda_files = { '~/project/my/archive/org/*' },
        notifications = {
          enabled = true,
        }
      }
      local default_notes_file = '~/project/my/archive/org/refile.org'
      default_notes_file = vim.fn.expand(default_notes_file)
      if vim.fn.filereadable(default_notes_file) == 1 then
        config.org_default_notes_file = default_notes_file
      end
      require('orgmode').setup_ts_grammar()
      require('orgmode').setup(config)
    end
  },
  -- markdown preview
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && npm install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
  -- neovim in browser
  {
    'glacambre/firenvim',
    cond = not vim.g.vscode,
    build = function() vim.fn['firenvim#install'](0) end
  },
  -- db manage
  {
    'tpope/vim-dadbod',
    cond = not vim.g.vscode
  },
  {
    'kristijanhusak/vim-dadbod-ui',
    cond = not vim.g.vscode
  },
  -- powerful replace tool
  {
    'windwp/nvim-spectre',
    cond = not vim.g.vscode
  },
  -- remote develop
  -- {
  --   'miversen33/netman.nvim',
  --   cond = not vim.g.vscode,
  --   config = function() require('netman') end
  -- },
  {
    'uga-rosa/translate.nvim',
    cmd = 'Translate',
    cond = not vim.g.vscode,
    config = function()
      local default_command = 'google'
      -- if vim.fn.executable('trans') then
      --   default_command = 'translate_shell'
      -- end
      require('translate').setup({
        default = {
          command = default_command
        },
      })
    end
  },
  {
    'folke/which-key.nvim',
    cond = not vim.g.vscode,
    config = function()
      require('which-key').setup()
      local wk = require('which-key')
      wk.register({
        f = {
          name = 'Telescope Finder',
          i = { name = 'BuildIn | Reloader' },
          m = { name = 'Mark' },
          h = { name = 'History | Help | Highlight' },
          w = { name = 'Workspace | LSP Action' },
          s = { name = 'Spectre' },
        },
        c = { name = 'Code' },
        d = { name = 'DAP' },
        o = { name = 'Orgmode' },
        m = { name = 'Markdown | Format | Marks' },
        r = { name = 'Rename | Rest' },
        s = { name = 'Source | Session' },
        t = { name = 'Translate' },
        w = { name = 'Workspace' },
        g = { name = 'Git' }
      }, { prefix = '<leader>' })
    end
  },
  {
    'echasnovski/mini.bufremove',
    version = '*',
    config = function()
      require('mini.bufremove').setup()
    end
  },
  {
    'echasnovski/mini.sessions',
    cond = not vim.g.vscode,
    version = '*',
    config = function()
      local function shutdown_term()
        local terms = require('toggleterm.terminal')
        local terminals = terms.get_all()
        for _, terminal in pairs(terminals) do
          terminal:shutdown()
        end
      end
      require('mini.sessions').setup({
        directory = vim.fn.stdpath('state') .. '/sessions/',
        file = 'session.vim',
        hooks = {
          -- Before successful action
          pre = { read = nil, write = shutdown_term, delete = nil },
          -- After successful action
          post = { read = nil, write = nil, delete = nil },
        },
      })
    end
  },
}
