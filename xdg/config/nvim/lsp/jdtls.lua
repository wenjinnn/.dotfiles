local util = require('wenvim.util')
local jdtls = require('jdtls')
local function setup_dap()
  jdtls.setup_dap()
  require('jdtls.dap').setup_dap_main_class_configs({
    config_overrides = { vmArgs = os.getenv('JDTLS_DAP_VMARGS') or '-Xms128m -Xmx512m' },
  })
  -- for all launch.json options see https://github.com/microsoft/vscode-java-debug#options
  require('dap.ext.vscode').load_launchjs()
end

local function setup_jdtls_buf_keymap(bufnr)
  local map = util.buf_map(bufnr)
  local jdtls_tests = require('jdtls.tests')
  map('n', '<leader>cC', '<cmd>JdtCompile full<CR>', 'Jdt compile full')
  map('n', '<leader>cc', '<cmd>JdtCompile incremental<CR>', 'Jdt compile incremental')
  map('n', '<leader>cu', '<cmd>JdtUpdateHotcode<CR>', 'Jdt update hotcode')
  map('n', '<leader>cg', jdtls_tests.generate, 'Jdt test generate')
  map('n', '<leader>co', jdtls.organize_imports, 'Jdt Organize Imports')
  map('n', '<leader>cv', jdtls.extract_variable, 'Jdt Extract Variable')
  map('n', '<leader>cT', jdtls_tests.goto_subjects, 'Jdt Test Goto Subjects')
  -- If using nvim-dap
  -- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
  map('n', '<leader>da', jdtls.test_class, 'Jdt Test Class')
  map('n', '<leader>dm', jdtls.test_nearest_method, 'Jdt Test Method')
  map('n', '<leader>cV', jdtls.extract_constant, 'Jdt Extract Constant')
  map('v', '<leader>cv', function() jdtls.extract_variable(true) end, 'Jdt Extract Variable')
  map('v', '<leader>cV', function() jdtls.extract_constant(true) end, 'Jdt Extract Constant')
  map('v', '<leader>ce', function() jdtls.extract_method(true) end, 'Jdt Extract Method')
end
local on_attach = function(client, bufnr)
  setup_dap()
  setup_jdtls_buf_keymap(bufnr)
end
local root_dir = vim.fs.root(0, { 'mvnw', 'gradlew', '.git', '.svn' })
local ws_name, _ = string.gsub(vim.fn.fnamemodify(root_dir, ':p'), '/', '_')
local jdtls_data_path = vim.fn.stdpath('data') .. '/jdtls'
local jdtls_debug_path = os.getenv('JAVA_DEBUG_PATH') or jdtls_data_path
local jdtls_test_path = os.getenv('JAVA_TEST_PATH') or jdtls_data_path

local bundles = { vim.fn.glob(jdtls_debug_path .. '/server/com.microsoft.java.debug.plugin-*.jar') }
local test_bundles = vim.split(vim.fn.glob(jdtls_test_path .. '/server/*.jar', true), '\n')
vim.list_extend(bundles, test_bundles)

local jdtls_cache_path = vim.fn.stdpath('cache') .. '/jdtls'
local lombok_path = os.getenv('LOMBOK_PATH')
local home = os.getenv('HOME')
local jdtls_maven_settings = os.getenv('JDTLS_MAVEN_SETTINGS')
local java8_home = os.getenv('JAVA8_HOME')
local java17_home = os.getenv('JAVA17_HOME')
local java21_home = os.getenv('JAVA21_HOME')
local config_path = vim.fn.stdpath('config')
return {
  settings = {
    java = {
      settings = { url = config_path .. '/after/lsp/jdtls.settings.prefs' },
      eclipse = { downloadSources = true },
      symbols = { includeSourceMethodDeclarations = true },
      selectionRange = { enabled = true },
      format = {
        enabled = true,
        comments = { enabled = false },
        onType = { enabled = false },
      },
      maxConcurrentBuilds = 5,
      saveActions = { organizeImports = false },
      referencesCodeLens = { enabled = true },
      implementationCodeLens = 'all',
      signatureHelp = {
        enabled = true,
        description = { enabled = true },
      },
      inlayHints = {
        parameterNames = { enabled = 'all' },
      },
      contentProvider = { preferred = 'fernflower' },
      templates = {
        typeComment = {
          '/**',
          ' * @author: ${user}',
          ' * @date: ${date}',
          ' * @description: ',
          ' */',
        },
      },
      import = {
        gradle = { enabled = true },
        maven = { enabled = true },
        exclusions = {
          '**/node_modules/**',
          '**/.metadata/**',
          '**/archetype-resources/**',
          '**/META-INF/maven/**',
          '**/Frontend/**',
          '**/CSV_Aggregator/**',
        },
      },
      maven = {
        downloadSources = true,
      },
      autobuild = { enabled = true },
      completion = {
        maxResults = 0,
        filteredTypes = {
          'com.sun.*',
          'io.micrometer.shaded.*',
          'java.awt.*',
          'jdk.*',
          'sun.*',
        },
        overwrite = false,
        guessMethodArguments = true,
        favoriteStaticMembers = {
          'org.hamcrest.MatcherAssert.assertThat',
          'org.hamcrest.Matchers.*',
          'org.hamcrest.CoreMatchers.*',
          'org.junit.jupiter.api.Assertions.*',
          'java.util.Objects.requireNonNull',
          'java.util.Objects.requireNonNullElse',
          'org.mockito.Mockito.*',
        },
      },
      project = {
        resourceFilters = {
          'build',
          'node_modules',
          '\\.git',
          '\\.idea',
          '\\.cache',
          '\\.vscode',
          '\\.settings',
        },
      },
      sources = {
        organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
      },
      codeGeneration = {
        generateComments = true,
        useBlocks = true,
        toString = {
          template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
        },
      },
      configuration = {
        updateBuildConfiguration = 'automatic',
        maven = {
          globalSettings = '/opt/maven/conf/settings.xml',
          userSettings = jdtls_maven_settings or home .. '/.m2/settings.xml',
        },
        runtimes = {
          {
            name = 'JavaSE-1.8',
            path = java8_home or '/usr/lib/jvm/java-8-openjdk/',
            default = true,
          },
          {
            name = 'JavaSE-17',
            path = java17_home or '/usr/lib/jvm/java-17-openjdk/',
          },
          {
            name = 'JavaSE-21',
            path = java21_home or '/usr/lib/jvm/java-21-openjdk/',
          },
        },
      },
    },
  },
  root_dir = root_dir,
  on_attach = on_attach,
  init_options = {
    bundles = bundles,
  },
  handlers = {
    -- filter noisy notifications
    ['$/progress'] = function(err, result, ctx)
      local msg = result.value.message
      if msg and msg:sub(1, 18) == 'Validate documents' then return end
      if msg and msg:sub(1, 19) == 'Publish Diagnostics' then return end
      -- pass through to normal handler
      vim.lsp.handlers['$/progress'](err, result, ctx)
    end,
  },
  cmd = {
    'jdtls',
    -- The following 6 lines is for optimize memory use, see https://github.com/redhat-developer/vscode-java/pull/1262#discussion_r386912240
    '--jvm-arg=-XX:+UseParallelGC',
    '--jvm-arg=-XX:MinHeapFreeRatio=5',
    '--jvm-arg=-XX:MaxHeapFreeRatio=10',
    '--jvm-arg=-XX:GCTimeRatio=4',
    '--jvm-arg=-XX:AdaptiveSizePolicyWeight=90',
    '--jvm-arg=-Dsun.zip.disableMemoryMapping=true',
    '--jvm-arg=-Dlog.protocol=true',
    '--jvm-arg=-Dlog.level=ALL',
    '--jvm-arg=-Dfile.encoding=utf-8',
    '--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false',
    '--jvm-arg=-Xms256m',
    '--jvm-arg=-Xmx' .. (os.getenv('JDTLS_XMX') or '1G'),
    lombok_path ~= nil and string.format('--jvm-arg=-javaagent:%s/lombok.jar', lombok_path) or '',
    '-configuration',
    jdtls_cache_path .. '/config',
    '-data',
    jdtls_cache_path .. '/workspace/' .. ws_name,
  },
}
