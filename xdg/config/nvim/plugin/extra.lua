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
  vim.pack.add({ 'https://git.barrettruth.com/barrettruth/preview.nvim' })
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
  local acp_adapter = os.getenv('NVIM_AI_ACP_ADAPTER') or 'oh_my_pi'
  local http_adapter = os.getenv('NVIM_AI_HTTP_ADAPTER') or 'deepseek'
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
      acp = {
        pi = function()
          local helpers = require('codecompanion.adapters.acp.helpers')
          return {
            name = 'pi',
            formatted_name = 'Pi',
            type = 'acp',
            roles = {
              llm = 'assistant',
              user = 'user',
            },
            commands = {
              default = {
                'pi-acp',
              },
            },
            defaults = {
              mcpServers = {},
              timeout = 120000,
            },
            parameters = {
              protocolVersion = 1,
              clientCapabilities = {
                fs = { readTextFile = true, writeTextFile = true },
              },
              clientInfo = {
                name = 'CodeCompanion.nvim',
                version = '1.0.0',
              },
            },
            handlers = {
              setup = function(self) return true end,
              auth = function(self) return true end,
              form_messages = function(self, messages, capabilities)
                return helpers.form_messages(self, messages, capabilities)
              end,
              on_exit = function(self, code) end,
            },
          }
        end,
        oh_my_pi = function()
          local helpers = require('codecompanion.adapters.acp.helpers')
          return {
            name = 'oh-my-pi',
            formatted_name = 'oh-my-pi',
            type = 'acp',
            roles = {
              llm = 'assistant',
              user = 'user',
            },
            commands = {
              default = {
                'omp',
                'acp',
              },
            },
            defaults = {
              mcpServers = {},
              timeout = 120000,
            },
            parameters = {
              protocolVersion = 1,
              clientCapabilities = {
                fs = { readTextFile = true, writeTextFile = true },
              },
              clientInfo = {
                name = 'CodeCompanion.nvim',
                version = '1.0.0',
              },
            },
            handlers = {
              setup = function(self) return true end,
              auth = function(self) return true end,
              form_messages = function(self, messages, capabilities)
                return helpers.form_messages(self, messages, capabilities)
              end,
              on_exit = function(self, code) end,
            },
          }
        end,
      },
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
        mimo = extend_adapter('openai_compatible', {
          env = {
            url = 'https://token-plan-cn.xiaomimimo.com',
            api_key = get_api_key('MIMO_API_KEY'),
            chat_url = '/v1/chat/completions',
          },
        }),
      },
    },
    interactions = {
      background = { adapter = acp_adapter },
      chat = { adapter = acp_adapter },
      inline = { adapter = acp_adapter },
      cmd = { adapter = http_adapter },
      cli = {
        agent = 'pi',
        agents = {
          pi = { cmd = 'pi', args = {}, description = 'Pi Agent' },
          oh_my_pi = { cmd = 'omp', args = {}, description = 'Oh my pi Agent' },
          claude = { cmd = 'claude', args = {}, description = 'Claude Code Agent' },
          opencode = { cmd = 'opencode', args = {}, description = 'Opencode Agent' },
          gemini = { cmd = 'gemini', args = {}, description = 'Gemini Agent' },
          codex = { cmd = 'codex', args = {}, description = 'OpenAI Codex Agent' },
        },
      },
    },
  })

  map({ 'n', 'v' }, '<leader>Ca', '<cmd>CodeCompanionActions<cr>', 'Open Code Companion actions menu')
  map({ 'n', 'v' }, '<leader>CC', '<cmd>CodeCompanionChat Toggle<cr>', 'Toggle Code Companion chat window')
  map({ 'n', 'v' }, '<leader>Cc', '<cmd>CodeCompanionCLI Ask<cr>', 'Ask Code Companion ACP cli')
  map('v', '<leader>CA', '<cmd>CodeCompanionChat Add<cr>', 'Add selection to Code Companion chat context')

  -- AI completion
  vim.pack.add({ gh('milanglacier/minuet-ai.nvim') })
  require('minuet').setup({
    virtualtext = {
      auto_trigger_ft = { '*' },
      keymap = {
        -- accept whole completion
        accept = '<A-w>',
        -- accept one line
        accept_line = '<A-j>',
        -- accept n lines (prompts for number)
        -- e.g. "A-z 2 CR" will accept 2 lines
        accept_n_lines = '<A-z>',
        -- Cycle to prev completion item, or manually invoke completion
        prev = '<A-p>',
        -- Cycle to next completion item, or manually invoke completion
        next = '<A-n>',
        dismiss = '<A-e>',
      },
      show_on_completion_menu = true,
    },
    provider = 'openai_fim_compatible',
    provider_options = {
      openai_fim_compatible = {
        model = 'deepseek-v4-flash',
        end_point = 'https://api.deepseek.com/beta/completions',
        api_key = get_api_key('DEEPSEEK_API_KEY'),
        name = 'deepseek',
        optional = {
          stop = { '\n\n' },
          max_tokens = 256,
          top_p = 0.9,
        },
      },
    },
    duet = {
      provider = 'openai_compatible',
      provider_options = {
        openai_compatible = {
          model = 'deepseek-v4-flash',
          end_point = 'https://api.deepseek.com/chat/completions',
          api_key = get_api_key('DEEPSEEK_API_KEY'),
          optional = {
            thinking = { type = 'disabled' },
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
