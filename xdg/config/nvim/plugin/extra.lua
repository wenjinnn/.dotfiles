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
  vim.pack.add({ gh('olimorris/codecompanion.nvim') })
  local default_adapter = os.getenv('NVIM_CC_ADAPTER') or 'claude_code'
  local get_api_key = function(key)
    local key_cmd = "sops exec-env $SOPS_SECRETS 'echo -n $%s'"
    return function() return vim.fn.system(key_cmd:format(key)) end
  end
  local function extend_adapter(adapter, key_or_set)
    local extend_set = key_or_set
    if type(key_or_set) == 'string' then extend_set = { env = { api_key = get_api_key(key_or_set) } } end
    return function() return require('codecompanion.adapters').extend(adapter, extend_set) end
  end

  require('codecompanion').setup({
    adapters = {
      http = {
        anthropic = extend_adapter('anthropic', 'ANTHROPIC_API_KEY'),
        deepseek = extend_adapter('deepseek', 'DEEPSEEK_API_KEY'),
        gemini = extend_adapter('gemini', 'GEMINI_API_KEY'),
        openrouter = extend_adapter('openai_compatible', {
          env = {
            url = 'https://openrouter.ai/api',
            api_key = get_api_key('OPENROUTER_API_KEY'),
            chat_url = '/v1/chat/completions',
          },
        }),
      },
    },
    interactions = {
      background = { adapter = default_adapter },
      chat = { adapter = default_adapter },
      inline = { adapter = default_adapter },
      cmd = { adapter = default_adapter },
    },
  })

  map({ 'n', 'v' }, '<leader>Ca', '<cmd>CodeCompanionActions<cr>', 'Open Code Companion actions menu')
  map({ 'n', 'v' }, '<leader>Ch', '<cmd>CodeCompanionHistory<cr>', 'Open Code Companion history list')
  map({ 'n', 'v' }, '<leader>CC', '<cmd>CodeCompanionChat Toggle<cr>', 'Toggle Code Companion chat window')
  map('v', '<leader>CA', '<cmd>CodeCompanionChat Add<cr>', 'Add selection to Code Companion chat context')

  -- Expand 'cc' into 'CodeCompanion' in the command line
  vim.cmd([[cab cc CodeCompanion]])

  -- AI completion
  vim.pack.add({ gh('milanglacier/minuet-ai.nvim') })
  require('minuet').setup({
    lsp = {
      inline_completion = {
        enable = true,
      },
    },
    provider = 'openai_fim_compatible',
    provider_options = {
      openai_fim_compatible = {
        model = 'deepseek-v4-flash',
        api_key = get_api_key('DEEPSEEK_API_KEY'),
        name = 'deepseek',
        optional = {
          max_tokens = 256,
          top_p = 0.9,
        },
      },
    },
    duet = {
      provider = 'gemini',
      provider_options = {
        gemini = {
          model = 'gemini-3-flash-preview',
          api_key = get_api_key('GEMINI_API_KEY'),
          optional = {
            generationConfig = {
              thinkingConfig = {
                -- Disable thinking is recommended
                thinkingLevel = 'minimal',
              },
            },
          },
        },
        openai_compatible = {
          model = 'minimax/minimax-m2.7',
          api_key = get_api_key('OPENROUTER_API_KEY'),
          optional = {
            reasoning_effort = 'minimal',
            -- prioritize throughput for faster completion
            provider = {
              sort = 'throughput',
            },
          },
        },
      },
    },
  })

  map({ 'n', 'i' }, '<A-d>', '<cmd>Minuet duet predict<cr>', 'Minuet duet predict')
  map({ 'n', 'i' }, '<A-a>', '<cmd>Minuet duet apply<cr>', 'Minuet duet apply')
  map({ 'n', 'i' }, '<A-x>', '<cmd>Minuet duet dismiss<cr>', 'Minuet duet dismiss')
end)
