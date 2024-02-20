return {
  -- rest client
  {
    'NTBBloodbath/rest.nvim',
    cond = not vim.g.vscode,
    main = 'rest-nvim',
    config = true,
    ft = { 'http' },
    keys = {
      { '<leader>re', '<plug>RestNvim' },
      { '<leader>rp', '<plug>RestNvimPreview' },
      { '<leader>rr', '<plug>RestNvimLast' },
    }
  },
  {
    'nvim-orgmode/orgmode',
    cond = not vim.g.vscode,
    event = 'VeryLazy',
    opts = function()
      require('orgmode').setup_ts_grammar()
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
      return config
    end
  },
  -- markdown preview
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    keys = {
      { '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>' }
    },
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
    lazy = not vim.g.started_by_firenvim,
    build = function() vim.fn['firenvim#install'](0) end
  },
  -- db manage
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod' },
    },
    keys = {
      { '<leader><leader>d', '<cmd>DBUIToggle<cr>' }
    },
    cond = not vim.g.vscode,
    cmd = 'DBUIToggle'
  },
  -- powerful replace tool
  {
    'windwp/nvim-spectre',
    cond = not vim.g.vscode,
    keys = {
      { '<leader>fss', '<cmd>lua require("spectre").toggle()<CR>',                        desc = 'Toggle Spectre' },
      { '<leader>fsw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', desc = 'Spectre Search current word' },
      { '<leader>fsw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', mode = 'v',                          desc = 'Spectre Search current word' },
      {
        '<leader>fsf',
        '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
        desc =
        'Search on current file',
      }
    }
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
    keys = {
      -- Display translation in a window
      { '<leader>tt', '<cmd>Translate ZH<CR>' },
      { '<leader>tt', '<cmd>Translate ZH<CR>' },
      -- Replace the text with translation
      { '<leader>tr', '<cmd>Translate ZH -output=replace<CR>' },
      { '<leader>tr', '<cmd>Translate ZH -output=replace<CR>' },
      -- Insert the text with translation
      { '<leader>ti', '<cmd>Translate ZH -output=insert<CR>' },
      { '<leader>ti', '<cmd>Translate ZH -output=insert<CR>' },
      -- copy translation to register
      { '<leader>ty', '<cmd>Translate ZH -output=register<CR>' },
      { '<leader>ty', '<cmd>Translate ZH -output=register<CR>' },
    },
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
    event = 'VeryLazy',
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
    keys = {
      { '<leader>x', '<cmd>lua MiniBufremove.delete()<CR>' }
    },
    version = '*',
    config = true,
  },
  {
    'echasnovski/mini.sessions',
    cond = not vim.g.vscode,
    lazy = true,
    priority = 100,
    event = 'VimEnter',
    keys = {
      { '<leader>sw', '<cmd>:lua MiniSessions.write((vim.fn.getcwd():gsub("/", "_")))<CR>' },
      { '<leader>ss', '<cmd>:lua MiniSessions.select()<CR>' },
      { '<leader>sd', '<cmd>:lua MiniSessions.delete((vim.fn.getcwd():gsub("/", "_")))<CR>' },
    },
    version = '*',
    opts = function()
      local function shutdown_term()
        local terms = require('toggleterm.terminal')
        local terminals = terms.get_all()
        for _, terminal in pairs(terminals) do
          terminal:shutdown()
        end
      end
      return {
        directory = vim.fn.stdpath('state') .. '/sessions/',
        file = 'session.vim',
        hooks = {
          -- Before successful action
          pre = { read = nil, write = shutdown_term, delete = nil },
          -- After successful action
          post = { read = nil, write = nil, delete = nil },
        },
      }
    end
  },
}
