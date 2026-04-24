if vim.g.vscode then return end

local util = wenvim.util
local map = util.map
local gh = util.gh
local later = util.later
later(function()
  -- ascii draw in neovim
  vim.pack.add({ gh('jbyuki/venn.nvim') })
  map('v', '<leader>vv', ':VBox<cr>', 'Draw a single line box or arrow')
  map('v', '<leader>vd', ':VBoxD<cr>', 'Draw a double line box or arrow')
  map('v', '<leader>vh', ':VBoxH<cr>', 'Draw a heavy line box or arrow')
  map('v', '<leader>vo', ':VBoxO<cr>', 'Draw over a existing box or arrow')
  map('v', '<leader>vO', ':VBoxDO<cr>', 'Draw over a doulbe line on a existing box or arrow')
  map('v', '<leader>vH', ':VBoxHO<cr>', 'Draw over a heavy line on a existing box or arrow')
  map('v', '<leader>vf', ':VFill<cr>', 'Draw fill a area with a solid color')

  -- curl client in neovim
  vim.pack.add({ gh('oysandvik94/curl.nvim') })
  require('curl').setup()

  -- markdown, html, asciidoc, svg preview in browser
  vim.pack.add({ gh('barrettruth/preview.nvim') })
  vim.g.preview = {
    markdown = {
      extra_args = { '-F', 'mermaid-filter' },
      output = function(ctx) return '/tmp/' .. vim.fn.fnamemodify(ctx.file, ':t:r') .. '.html' end,
    },
  }

  -- db manage
  vim.pack.add({ gh('tpope/vim-dadbod'), gh('kristijanhusak/vim-dadbod-completion') })
  vim.api.nvim_create_autocmd('FileType', {
    group = util.augroup('dadbod'),
    pattern = 'sql',
    callback = function(ev)
      vim.bo[ev.buf].omnifunc = 'vim_dadbod_completion#omni'
      map({ 'n', 'x' }, '<CR>', 'db#op_exec()', { expr = true, desc = 'DB exec current query' })
    end,
  })

  -- AI assistant
  vim.pack.add({ gh('olimorris/codecompanion.nvim'), gh('ravitemer/codecompanion-history.nvim') })
  local default_adapter = os.getenv('NVIM_AI_ADAPTER') or 'copilot'
  local ollama_model = os.getenv('NVIM_OLLAMA_MODEL') or 'deepseek-r1:14b'
  local openrouter_model = os.getenv('NVIM_OPENROUTER_MODEL') or 'anthropic/claude-sonnet-4.6'
  local api_key_cmd = "sops exec-env $SOPS_SECRETS 'echo -n $%s'"
  local ollama_setting = { schema = { model = { default = ollama_model } } }

  local function extend_adapter(adapter, key_or_set)
    local extend_set = key_or_set
    if type(key_or_set) == 'string' then
      extend_set = { env = { api_key = 'cmd:' .. api_key_cmd:format(key_or_set) } }
    end
    return function() return require('codecompanion.adapters').extend(adapter, extend_set) end
  end

  require('codecompanion').setup({
    adapters = {
      http = {
        ollama = extend_adapter('ollama', ollama_setting),
        anthropic = extend_adapter('anthropic', 'ANTHROPIC_API_KEY'),
        deepseek = extend_adapter('deepseek', 'DEEPSEEK_API_KEY'),
        gemini = extend_adapter('gemini', 'GEMINI_API_KEY'),
        openrouter = extend_adapter('openai_compatible', {
          env = {
            url = 'https://openrouter.ai/api',
            api_key = api_key_cmd:format('OPENROUTER_API_KEY'),
            chat_url = '/v1/chat/completions',
          },
          schema = { model = { default = openrouter_model } },
        }),
      },
    },
    interactions = {
      background = { adapter = default_adapter },
      chat = { adapter = default_adapter },
      inline = { adapter = default_adapter },
      cmd = { adapter = default_adapter },
    },
    extensions = { history = { enabled = true } },
  })
  map({ 'n', 'v' }, '<leader>Ca', '<cmd>CodeCompanionActions<cr>', 'Open Code Companion actions menu')
  map({ 'n', 'v' }, '<leader>CC', '<cmd>CodeCompanionChat Toggle<cr>', 'Toggle Code Companion chat window')
  map('v', '<leader>CA', '<cmd>CodeCompanionChat Add<cr>', 'Add selection to Code Companion chat context')

  -- Expand 'cc' into 'CodeCompanion' in the command line
  vim.cmd([[cab cc CodeCompanion]])

  -- AI completion
  vim.pack.add({ gh('milanglacier/minuet-ai.nvim') })
  require('minuet').setup({
    virtualtext = {
      auto_trigger_ft = {},
      keymap = {
        -- accept whole completion
        accept = '<A-A>',
        -- accept one line
        accept_line = '<A-a>',
        -- accept n lines (prompts for number)
        -- e.g. "A-n 2 CR" will accept 2 lines
        accept_n_lines = '<A-n>',
        -- Cycle to prev completion item, or manually invoke completion
        prev = '<A-[>',
        -- Cycle to next completion item, or manually invoke completion
        next = '<A-]>',
        dismiss = '<A-e>',
      },
    },
    provider = 'openai_fim_compatible',
    provider_options = {
      openai_fim_compatible = {
        api_key = function() return vim.system(api_key_cmd:format('DEEPSEEK_API_KEY')) end,
        name = 'deepseek',
        optional = {
          max_tokens = 256,
          top_p = 0.9,
        },
      },
    },
  })
end)
